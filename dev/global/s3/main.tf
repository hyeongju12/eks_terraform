resource "aws_s3_bucket" "dev-tfstate-bucket" {
    bucket = "hjyoo-dev-tfstate-bucket-3"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "dev-s3-versioning" {
    bucket = aws_s3_bucket.dev-tfstate-bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
    bucket = aws_s3_bucket.dev-tfstate-bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }   
    }   
}

