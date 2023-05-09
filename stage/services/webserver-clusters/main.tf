provider "aws" {}

terraform {
    backend "s3" {
        bucket = "hjyoo-tf-project-state"
        key = "stage/services/webserver/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "hjyoo-tf-project-locks"
        encrypt = true
    }
}

