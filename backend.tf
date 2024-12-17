terraform {
  backend "s3" {
    acl     = "bucket-owner-full-control"
    bucket  = "us-east-1-csgp-terraform-state"
    encrypt = true
    region  = "us-east-1"
  }
}