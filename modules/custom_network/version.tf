############################################
# version of terraform and providers
############################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.0"
    }
  }
}
