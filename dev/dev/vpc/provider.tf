provider "aws" {
    profile = "dev"
    region = "us-east-1"
}

terraform {
    backend "s3" {
        profile = "dev"
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "hjyoo-tf-project-locks"
        encrypt = true
    }
}