variable "APP_NAME" {
    default = "nginx-demo"
}

variable "NAMESPACE" {
    default = "default"
}

variable "AWS_REGION" {
    default = "us-east-1"
}

variable "SERVICE_NAME" {
    default = "nginx-demo-svc"
}

variable "aws_access_key" {
    description = "aws configure access key"
}

variable "aws_secret_key" {
    description = "aws configure secret key"
}