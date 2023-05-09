resource "aws_dynamodb_table" "tf-locks" {
    name = "hjyoo-tf-project-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}