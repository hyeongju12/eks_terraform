data "terraform_remote_state" "db" {
    backend = "s3"
    config = {
        bucket = "hjyoo-tf-project-state"
        key = "stage/rds/mysql/terraform.tfstate"
        region = "us-east-1"
    }
}

data "template_file" "user_data" {
    template = file("/Users/hyeongjuyou/Aws/terraform/stage/services/webserver-clusters/user_data.sh")
    vars = {
        db_address = data.terraform_remote_state.db.outputs.mysql_endpoint
        db_port = data.terraform_remote_state.db.outputs.port
        server_port = var.webserver_port
    }

}

resource "aws_launch_configuration" "example" {
    name_prefix   = "example"
    image_id      = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]
    user_data = data.template_file.user_data.rendered
    lifecycle {
    create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnets.example.ids
    desired_capacity = 2
    min_size=2
    max_size=10

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

resource "aws_instance" "example" {
    ami = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello World" > index.html
        echo "${data.terraform_remote_state.db.outputs.mysql_endpoint}" >> index.html
        echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
        nohup busybox httpd -f -p ${var.webserver_port} &
        EOF

    tags = {
        "Name" = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = var.webserver_port
        to_port = var.webserver_port
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