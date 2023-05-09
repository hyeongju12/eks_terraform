output "public_ip" {
    value = aws_instance.example.public_ip
    description = "This is example ec2 public ip"
}

output "alb_dns" {
    value = aws_lb.example.dns_name
    description = "ALB DNS"
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "aws_s3_bucket_arn"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "The name of Dynamodb table"
}