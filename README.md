# Copy Kubernetes Resources Script

This script automates the process of copying Kubernetes resources from a source cluster to a destination cluster. It handles namespaces, deployments, services, secrets, configmaps, and other resources, providing support for conflict resolution and rollback mechanisms.

## Features
- Copy resources between Kubernetes clusters.
- Supports specific namespaces, wildcard namespace patterns, or all namespaces.
- Handles conflict resolution with retry logic.
- Provides rollback functionality in case of errors.
- Supports `namespace`, `deployments`, `hpa`, `svc`, `virtualservice`, `secret`, and `configmap` resources.

## Prerequisites
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured.
- Access to both source and destination Kubernetes clusters.
- [yq](https://github.com/mikefarah/yq) installed for YAML processing.

## Usage

### Command Syntax
```bash
./copy-resources.sh <source-cluster-context> <destination-cluster-context> [<namespace or wildcard>]
```

- `<source-cluster-context>`: The context of the source Kubernetes cluster.
- `<destination-cluster-context>`: The context of the destination Kubernetes cluster.
- `[<namespace or wildcard>]` (optional): Specify a namespace or use wildcard (`*`) for multiple namespaces. If omitted, all namespaces will be processed.

### Examples
#### Copy a Single Namespace
```bash
./copy-resources.sh source-context destination-context my-namespace
```

#### Copy Namespaces Using Wildcard
```bash
./copy-resources.sh source-context destination-context "my-namespace-*"
```

#### Copy All Namespaces
```bash
./copy-resources.sh source-context destination-context
```

## How It Works
1. **Switch Contexts**: Validates and switches between source and destination Kubernetes contexts.
2. **Namespace Selection**: Retrieves namespaces based on the user input (specific, wildcard, or all).
3. **Export Resources**: Extracts YAML definitions of the resources from the source cluster and cleans them using `yq`.
4. **Apply Resources**: Applies the cleaned resources to the destination cluster, with retry logic for conflicts.
5. **Rollback (if necessary)**: Deletes applied resources in case of failure.

## Rollback Mechanism
If any resource fails to apply after the maximum retries, the script rolls back all applied resources using the `applied_resources.txt` file, ensuring the destination cluster remains unaffected.

## Conflict Resolution
The script retries applying resources up to three times (`MAX_RETRIES`) if conflicts occur. It fetches the latest resource version from the destination cluster and merges it with the source YAML.

## Validation Prompt
After applying resources, the script prompts for user validation:
```bash
Resources have been applied. Please validate.
Did everything apply successfully? (yes/no):
```
If "no" is selected, a rollback is performed.

## Dependencies
- `kubectl`
- `yq`

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! Open an issue or submit a pull request to improve the script.
