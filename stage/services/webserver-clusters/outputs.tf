output "public_ip" {
    value = aws_instance.example.public_ip
    description = "This is example ec2 public ip"
}

output "alb_dns" {
    value = aws_lb.example.dns_name
    description = "ALB DNS"
}