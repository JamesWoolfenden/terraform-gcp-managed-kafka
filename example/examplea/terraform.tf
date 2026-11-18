# holden:ignore:HLD_TF_004
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.31.0"
    }
  }
  required_version = ">= 1.9.0" # cross-variable validation (var.region referenced from var.kms_key_name's validation) requires 1.9+
}
