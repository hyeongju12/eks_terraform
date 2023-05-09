provider "aws" {
    region = "us-east-1"
}

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-and-running-hjyoo"
    engine = "mysql"
    engine_version = "8.0.32"
    allocated_storage = 10
    instance_class = "db.t2.micro"    
    name = "example_database"
    username = "admin"
    password = var.db_passwd
}

terraform {
    backend "s3" {
        bucket = "hjyoo-tf-project-state"
        key = "stage/rds/mysql/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "hjyoo-tf-project-locks"
        encrypt = true
    }
}