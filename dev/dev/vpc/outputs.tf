output "dev-subnet-1d-private-arn" {
    value = aws_subnet.dev-private-1d.arn
    description = "dev private-subnet-1d arn"
}

output "dev-subnet-1f-private-arn" {
    value = aws_subnet.dev-private-1f.arn
    description = "dev private-subnet-1f arn"
}

output "dev-subnet-1a-public-id" {
    value = aws_subnet.dev-public-1a.id
    description = "dev public-subnet-1a id"
}

output "dev-subnet-1c-public-id" {
    value = aws_subnet.dev-public-1c.id
    description = "dev pulbic-subnet-1c id"
}

output "dev-subnet-1d-private-id" {
    value = aws_subnet.dev-private-1d.id
    description = "dev private-subnet-1d id"
}

output "dev-subnet-1f-private-id" {
    value = aws_subnet.dev-private-1f.id
    description = "dev private-subnet-1f id"
}

output "dev-vpc-id" {
    value = aws_vpc.dev-vpc.id
    description = "DEV VPC ID"
}

output "dev-ssh-allow-sg" {
    value = aws_security_group.allow_ssh.id
    description = "DEV VPC ID"
}