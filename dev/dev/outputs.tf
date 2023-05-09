output "bastion_public_ip" {
    value = aws_instance.dev-bastion.public_ip
    description = "bastion public ip"
}