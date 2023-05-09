provider "aws" {
    profile = "dev"
    region = "us-east-1"
}

terraform {
    backend "s3" {
        profile = "dev"
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/cicd2/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "hjyoo-tf-project-locks"
        encrypt = true
    }
}

#cloud_user-at-349685560242
#l5EaK2NWYt8GiPrpC3cAqFSVx4K2Gt8/2NGPsP5GE/s=