locals {
    http_port = 80
    any_port = 0
    tcp_protocol = -1
    all_ips = ["0.0.0.0/0"]
}

resource "aws_lb" "alb" {
    name = "${var.cluster_name}-alb"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_security_group" "stage-alb-sg" {
    name = "${var.cluster-name}-alb-sg"
}

resource "aws_security_group_rule" "allow_inbound_rule" {
    security_group_id = module.webserver_clusters.alb_security_group_id
    type = "ingress"

    from_port = 12345
    to_port = 12345
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "allow_outbound_rule" {
    from_port = local.any_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    security_group_id = module.webserver_clusters.alb_security_group_id
    type = "egress"
    
}