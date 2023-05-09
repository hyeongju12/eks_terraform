output "mysql_endpoint" {
    value = aws_db_instance.example.address
    description = "mysql_endpoints"
}

output "port" {
    value = aws_db_instance.example.port
    description = "mysql_port"
}