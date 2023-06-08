data "terraform_remote_state" "network-config" {
    backend = "s3"

    config = {
        bucket = "hjyoo-dev-tfstate-bucket-3"
        key = "dev/vpc/terraform.tfstate"
        region = "us-east-1"
        profile = "dev"
    }
}

data "aws_iam_user" "cloud_user" {
    user_name = "cloud_user"
}

resource "aws_iam_role" "eks_cluster" {
    name = "eks-cluster"
    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "aws_eks" {
    name     = "eks_cluster"
    role_arn = aws_iam_role.eks_cluster.arn
    version = "1.24"
    
    kubernetes_network_config {
        service_ipv4_cidr = "10.100.0.0/24"
    }

    vpc_config {
        subnet_ids = [ data.terraform_remote_state.network-config.outputs.dev-subnet-1a-public-id, data.terraform_remote_state.network-config.outputs.dev-subnet-1c-public-id ]
        security_group_ids = [data.terraform_remote_state.network-config.outputs.dev-ssh-allow-sg]
    }
}

resource "aws_iam_role" "eks_nodes" {
    name = "eks-node-group"

    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
POLICY
}
resource "aws_iam_role" "cluster_autoscaler_role" {
    name = "cluster-autoscaler-role"
    assume_role_policy = jsonencode({
        Version   = "2012-10-17"
        Statement = [
        {
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
            Action    = "sts:AssumeRole"
        },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy_attachment" {
    policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
    role       = aws_iam_role.cluster_autoscaler_role.name
}


resource "aws_iam_policy" "cluster_autoscaler_policy" {
    name        = "cluster-autoscaler-policy"
    path        = "/"
    policy      = jsonencode({
        Version   = "2012-10-17"
        Statement = [
    {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": ["*"]
            },
            {
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": ["*"]
            }
        ]
    })
}


resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterAutoscalerPolicy" {
    policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
    role = aws_iam_role.eks_cluster.name
}

# resource "aws_eks_addon" "kube_proxy" {
#     cluster_name      = aws_eks_cluster.aws_eks.name
#     addon_name        = "kube-proxy"
#     addon_version     = "v1.25.6-minimal-eksbuild.1"
#     resolve_conflicts = "OVERWRITE"
# }

# resource "aws_eks_addon" "core_dns" {
#     cluster_name      = aws_eks_cluster.aws_eks.name
#     addon_name        = "coredns"
#     addon_version     = "v1.9.3-eksbuild.2"
#     resolve_conflicts = "OVERWRITE"
# }
resource "aws_launch_configuration" "eks_launch_conf" {
    image_id = "ami-06e46074ae430fba6"
    instance_type = "t2.small"

    security_groups = [ data.terraform_remote_state.network-config.outputs.dev-ssh-allow-sg ]
}

resource "aws_autoscaling_group" "eks_asg" {
    max_size = 3
    min_size = 1
    launch_configuration = aws_launch_configuration.eks_launch_conf.id
    
    vpc_zone_identifier = [data.terraform_remote_state.network-config.outputs.dev-subnet-1a-public-id, data.terraform_remote_state.network-config.outputs.dev-subnet-1c-public-id]

    tag {
        key = "kubernetes.io/cluster/${aws_eks_cluster.aws_eks.name}"
        value = "owned"
        propagate_at_launch = true
    }
}


resource "aws_eks_node_group" "node" {
    version = 1.27
    instance_types = ["t2.small"]
    cluster_name    = aws_eks_cluster.aws_eks.name
    node_group_name = "EKS-WORKER-NODE"
    node_role_arn   = aws_iam_role.eks_nodes.arn
    subnet_ids      = [ data.terraform_remote_state.network-config.outputs.dev-subnet-1a-public-id, data.terraform_remote_state.network-config.outputs.dev-subnet-1c-public-id ]

    scaling_config {
        desired_size = 1
        max_size     = 3
        min_size     = 1
    }

    tags = {
        Name = "WORKER-NODE"
    }

    # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
    # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
    depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    ]
}

# data "aws_partition" "current" {
    
# }

# data "external" "thumbprint" {
#     program = ["thumbprint.sh", "us-east-1"]
# }

# resource "aws_iam_openid_connect_provider" "oidc_provider" {
#     client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
#     thumbprint_list = [data.external.thumbprint.result.thumbprint]
#     url             = aws_eks_cluster.aws_eks.identity[0].oidc[0].issuer
# }

# output "aws_iam_openid_connect_provider_arn" {
#     description = "AWS IAM Open ID Connect Provider ARN"
#     value       = aws_iam_openid_connect_provider.oidc_provider.arn
# }



# locals {
#     aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
# }
# output "aws_iam_openid_connect_provider_extract_from_arn" {
#     description = "AWS IAM Open ID Connect Provider extract from ARN"
#     value       = local.aws_iam_oidc_connect_provider_extract_from_arn
# }