provider "aws" {
}

resource "aws_instance" "example" {
    ami = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-hjyoo2"
        key = "workspace-example2/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}