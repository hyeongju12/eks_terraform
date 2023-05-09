data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "example" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}
resource "aws_lb" "stage-alb" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.example.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.stage-alb.arn
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type             = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: Page not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example"
    port = var.webserver_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id
    health_check {
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}