# VPC
resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true

    tags = {
        "Name" = "dev-vpc"
    }
}

# VPC SecurityGroup

# Subnets
resource "aws_subnet" "dev-public-1a" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}


resource "aws_subnet" "dev-public-1c" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "dev-private-1d" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1d"
}

resource "aws_subnet" "dev-private-1f" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1f"
}

# Igw and IGW attachment
resource "aws_internet_gateway" "dev-igw-1" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev-igw-1"
    }
}

# NGW and NGW attachment
resource "aws_eip" "ngw-1-eip" {
    vpc = true
}

resource "aws_eip" "ngw-2-eip" {
    vpc = true
}

resource "aws_nat_gateway" "dev-ngw-1" {
    allocation_id = aws_eip.ngw-1-eip.id
    connectivity_type = "public"
    subnet_id         = aws_subnet.dev-public-1a.id
}

resource "aws_nat_gateway" "dev-ngw-2" {
    allocation_id = aws_eip.ngw-2-eip.id
    connectivity_type = "public"
    subnet_id         = aws_subnet.dev-public-1c.id
}

# dev-public-1a route table
resource "aws_route_table" "dev-public-1a" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev-public-1a"
    }
}

#dev-public-1a route association
resource "aws_route_table_association" "route-table-association-public-1a" {
    route_table_id = aws_route_table.dev-public-1a.id
    subnet_id = aws_subnet.dev-public-1a.id
}

# dev-public-1c route table
resource "aws_route_table" "dev-public-1c" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev-public-1c"
    }
}

#dev-private-1c route association
resource "aws_route_table_association" "route-table-association-public-1c" {
    route_table_id = aws_route_table.dev-public-1c.id
    subnet_id = aws_subnet.dev-public-1c.id
}

#dev-igw route
resource "aws_route" "igw-pubilc-1a-route" {
    route_table_id = aws_route_table.dev-public-1a.id
    gateway_id = aws_internet_gateway.dev-igw-1.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "igw-pubilc-1c-route" {
    route_table_id = aws_route_table.dev-public-1c.id
    gateway_id = aws_internet_gateway.dev-igw-1.id
    destination_cidr_block = "0.0.0.0/0"
}

# dev-public-2a route table
resource "aws_route_table" "dev-private-1d" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev-private-1d"
    }
}

#dev-private-2a route association
resource "aws_route_table_association" "route-table-association-pricvate-1d" {
    route_table_id = aws_route_table.dev-private-1d.id
    subnet_id = aws_subnet.dev-private-1d.id
}

# dev-public-2c route table
resource "aws_route_table" "dev-private-1f" {
    vpc_id = aws_vpc.dev-vpc.id

    tags = {
        Name = "dev-private-1e"
    }
}

#dev-private-2c route association
resource "aws_route_table_association" "route-table-association-private-1f" {
    route_table_id = aws_route_table.dev-private-1f.id
    subnet_id = aws_subnet.dev-private-1f.id
}



# dev-ngw-1 attachment route table
resource "aws_route" "dev-private-nat-1" {
    route_table_id = aws_route_table.dev-private-1d.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-ngw-1.id
}

# dev-ngw-2 attachment route table
resource "aws_route" "dev-private-nat-2" {
    route_table_id = aws_route_table.dev-private-1f.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-ngw-2.id
}

# SG
resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "Allow bastion-host"
    vpc_id = aws_vpc.dev-vpc.id
    
    ingress {
        cidr_blocks = [ "183.102.111.61/32", "10.0.1.0/24", "10.0.3.0/24", "10.0.2.0/24", "10.0.4.0/24"]
        description = "LOCAL PC SSH ALLOW"
        from_port = 22
        protocol = "tcp"
        to_port = 22
    } 

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "allow_kubectl" {
    from_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.allow_ssh.id
    cidr_blocks = [ "183.102.111.61/32", "10.0.1.0/24", "10.0.3.0/24", "10.0.2.0/24", "10.0.4.0/24"]
    to_port = 443
    type = "ingress"
}

resource "aws_security_group_rule" "allow_mount_efs" {
    from_port = 2049
    protocol = "tcp"
    security_group_id = aws_security_group.allow_ssh.id
    cidr_blocks = [ "183.102.111.61/32", "10.0.1.0/24", "10.0.3.0/24", "10.0.2.0/24", "10.0.4.0/24"]
    to_port = 2049
    type = "ingress"
}

resource "aws_security_group_rule" "allow_http" {
    from_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.allow_ssh.id
    cidr_blocks = [ "0.0.0.0/0" ]
    to_port = 80
    type = "ingress"
}