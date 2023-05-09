
data "terraform_remote_state" "dev-subnets" {
    backend = "s3"
    config = {        
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

data "terraform_remote_state" "dev_eks_config" {
    backend = "s3"
    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/eks/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

locals {
    cluster_name = data.terraform_remote_state.dev_eks_config.outputs.cluster_name
    access_key = var.access_key
    secret_key= var.secret_key
    region = var.region
    output = var.output
    profile_name = var.profile_name
}

resource "aws_key_pair" "bastion-key" {
    key_name = "bastion-key"
    public_key = file(var.key_path)
    
}

resource "aws_eip" "ec2-pubilc" {
    vpc = true
}

resource "aws_instance" "dev-bastion" {
    ami = "ami-007855ac798b5175e"
    instance_type = "t3.medium"
    subnet_id = data.terraform_remote_state.dev-subnets.outputs.dev-subnet-1a-public-id
    associate_public_ip_address = true
    key_name = aws_key_pair.bastion-key.key_name
    vpc_security_group_ids = [ data.terraform_remote_state.dev-subnets.outputs.dev-ssh-allow-sg ]

    provisioner "file" {
        destination = "/tmp/setting.sh"
        source = "./setting.sh"
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/setting.sh",
            "sudo sed -i -e 's/\r$//' /tmp/setting.sh",
            "sudo /tmp/setting.sh",
            "aws configure set aws_access_key_id ${local.access_key} --profile ${local.profile_name}",
            "aws configure set aws_secret_access_key ${local.secret_key} --profile ${local.profile_name}",
            "aws configure set region ${local.region} --profile ${local.profile_name}",
            "aws configure set output ${local.output} --profile ${local.profile_name}",
            "aws eks update-kubeconfig --name ${local.cluster_name} --profile ${local.profile_name} --region ${local.region}",
        ]
    }

    connection {
        host        = coalesce(self.public_ip, self.private_ip)
        type        = "ssh"
        user        = var.INSTANCE_USERNAME
        private_key = file(var.PATH_TO_PRIVATE_KEY)    
    }
}