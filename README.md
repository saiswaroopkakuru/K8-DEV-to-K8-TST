#!/bin/bash

# Set source and destination clusters
SOURCE_CONTEXT="$1"
DEST_CONTEXT="$2"
NAMESPACE="$3"

# Resources to export and apply (namespace is first)
RESOURCES=("namespace" "deployments" "hpa" "svc" "virtualservice" "secret" "configmap")

# File to track applied resources for rollback
APPLIED_RESOURCES_FILE="applied_resources.txt"

# Max number of retries for conflict resolution
MAX_RETRIES=3

# Check if source and destination contexts are passed as parameters
if [ -z "$SOURCE_CONTEXT" ] || [ -z "$DEST_CONTEXT" ]; then
  echo "Usage: ./copy-resources.sh <source-cluster-context> <destination-cluster-context> [<namespace or wildcard>]"
  exit 1
fi

# Function to check if the context is valid and switch to it
switch_context() {
  local context=$1
  echo "Switching to context: $context"
  kubectl config use-context "$context" &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error: Failed to switch to context $context. Please check if the context is correct."
    exit 1
  fi
  echo "Successfully switched to context: $context"
}

# Cleanup: Delete the applied resources in case of failure
cleanup_applied_resources() {
  if [ -f "$APPLIED_RESOURCES_FILE" ]; then
    echo "Rolling back applied resources..."
    while read -r line; do
      echo "Deleting $line..."
      kubectl delete -f $line
    done < "$APPLIED_RESOURCES_FILE"
    echo "Rollback completed."
  else
    echo "No resources applied, nothing to rollback."
  fi
}

# Function to get namespaces based on input (specific, wildcard, or all)
get_namespaces() {
  if [ -n "$NAMESPACE" ]; then
    # Wildcard namespace handling
    if [[ "$NAMESPACE" == *"*"* ]]; then
      echo "Selecting namespaces matching pattern: $NAMESPACE"
      kubectl get ns --no-headers -o custom-columns=":metadata.name" | grep -E "^${NAMESPACE/\*/.*}$"
    else
      # Single namespace
      echo "$NAMESPACE"
    fi
  else
    # All namespaces
    kubectl get ns --no-headers -o custom-columns=":metadata.name"
  fi
}

# Function to export resources from specific namespace(s)
export_resources() {
  for namespace in $1; do
    for resource in "${RESOURCES[@]}"; do
      if [ "$resource" == "namespace" ]; then
        # Special handling for namespace resource
        echo "Exporting namespace $namespace..."
        kubectl get $resource $namespace -o yaml > ${resource}_${namespace}.yaml
        # Clean up YAML (optional)
        yq eval 'del(.metadata.creationTimestamp, .metadata.resourceVersion, .metadata.uid, .status)' ${resource}_${namespace}.yaml -o yaml > clean-${resource}_${namespace}.yaml
      else
        echo "Exporting $resource from namespace $namespace..."
        kubectl get $resource -n $namespace -o yaml > ${resource}_${namespace}.yaml
        # Clean up YAML (optional)
        yq eval 'del(.metadata.creationTimestamp, .metadata.resourceVersion, .metadata.uid, .status)' ${resource}_${namespace}.yaml -o yaml > clean-${resource}_${namespace}.yaml
      fi
    done
  done
}

# Function to apply a resource with conflict handling
apply_with_retry() {
  resource_file=$1
  namespace=$2

  retries=0
  while [ $retries -lt $MAX_RETRIES ]; do
    echo "Applying resource from $resource_file to namespace $namespace..."

    kubectl apply -f "$resource_file" -n "$namespace"
    if [ $? -eq 0 ]; then
      echo "Successfully applied $resource_file"
      echo "$resource_file" >> "$APPLIED_RESOURCES_FILE"
      return 0
    else
      echo "Conflict detected. Retrying... ($((retries+1))/$MAX_RETRIES)"
      # Fetch the latest resource from the destination cluster
      kubectl get -f "$resource_file" -n "$namespace" -o yaml > latest-$resource_file
      # Retry by merging with the latest version
      cp latest-$resource_file "$resource_file"
      retries=$((retries+1))
    fi
  done

  echo "Failed to apply $resource_file after $MAX_RETRIES retries."
  return 1
}

# Function to apply namespace first, then other resources to the destination cluster
apply_resources() {
  # Clear previous applied resources file
  > "$APPLIED_RESOURCES_FILE"

  for namespace in $1; do
    # Apply the namespace first
    echo "Applying namespace $namespace in destination cluster..."
    apply_with_retry "clean-namespace_${namespace}.yaml" "$namespace"
    
    # Apply other resources in the namespace
    for resource in "${RESOURCES[@]}"; do
      if [ "$resource" != "namespace" ]; then
        echo "Applying $resource to namespace $namespace in destination cluster..."
        apply_with_retry "clean-${resource}_${namespace}.yaml" "$namespace"
      fi
    done
  done
}

# Main logic to export, apply resources, and validate
main() {
  # Switch to source context
  switch_context "$SOURCE_CONTEXT"

  # Get the list of namespaces based on input (single, wildcard, or all)
  NAMESPACES=$(get_namespaces)

  # Export resources from source cluster
  export_resources "$NAMESPACES"

  # Switch to destination context
  switch_context "$DEST_CONTEXT"

  # Apply resources to destination cluster (namespace first)
  apply_resources "$NAMESPACES"

  # Ask for validation after applying resources
  echo "Resources have been applied. Please validate."
  read -p "Did everything apply successfully? (yes/no): " VALIDATION

  if [ "$VALIDATION" == "no" ]; then
    echo "Something went wrong. Rolling back..."
    cleanup_applied_resources
    exit 1
  fi

  echo "Resources successfully copied from source to destination cluster."
}

# Start the process
main
