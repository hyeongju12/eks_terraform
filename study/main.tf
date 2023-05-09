resource "aws_iam_user" "name" {
    for_each = toset(var.user_name)
    name = each.value
}

resource "aws_launch_template" "foobar" {
    name_prefix   = "foobar"
    image_id      = "ami-02396cdd13e9a1257"
    instance_type = "t2.micro"
    }

resource "aws_autoscaling_group" "bar" {
    availability_zones = ["us-east-1a"]
    desired_capacity   = 1
    max_size           = 1
    min_size           = 1

    launch_template {
        id      = aws_launch_template.foobar.id
        version = "$Latest"
    }

    dynamic "tag" {
        for_each = var.custom_tags       
        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}