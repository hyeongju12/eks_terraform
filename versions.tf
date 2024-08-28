terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }

  # backend "s3" {
  # }
}
