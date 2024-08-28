project     = "IO"
env         = "DEV"
org         = "PSA"
region      = "ap-northeast-2"

vpc_id = "vpc-0c71bacd3c5dfd2eb"
subnet_ids = ["subnet-0bf322dee7f3f05ea", "subnet-0db0f92c685da47c4"]
cluster_name = "test-eks"
cluster_version = 1.27

cluster_endpoint_public_access = true
cluster_endpoint_private_access = true
node_security_group_enable_recommended_rules = false

iam_role_use_name_prefix = false
iam_role_name = "PSA-DEV-IAMROLE-EKS"

cluster_encryption_policy_use_name_prefix = false
# cluster_encryption_policy_name = ""

cluster_security_group_use_name_prefix = false
cluster_security_group_name = "PSA-DEV-IO-SG-EKS-AP2"

cluster_security_group_additional_rules = {
#  bastion_443 = {
#    cidr_blocks = ["172.28.19.55/32"]
#    description = "From_Bastion_443"
#    from_port = 443
#    protocol = "tcp"
#    to_port = 443
#    type = "ingress"
#  },
  cluster_egress_all = {
    cidr_blocks = ["0.0.0.0/0"]
    description = "cluster all egress"
    from_port = 0
    protocol = "-1"
    to_port = 0
    type = "egress"
  },
  egress_nodes_ports_tcp = {
    description = "To node 1025-65535"
    from_port = 1025
    protocol = "tcp"
    source_node_security_group = true
    to_port = 65535
    type = "egress"
  }
}

node_security_group_additional_rules = {
  ingress_all = {
    description = "Node to node all ports/protocols"
    from_port = 0
    protocol = "-1"
    self = true
    to_port = 0
    type = "ingress"
  },
  ingress_cluster = {
    description = "To cluster 1025-65535"
    from_port = 1025
    protocol = "tcp"
    source_cluster_security_group = true
    to_port = 65535
    type = "ingress"
  },
  node_egress_all = {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Node all egress"
    from_port = 0
    protocol = "-1"
    to_port = 0
    type = "egress"
  }
}

eks_managed_node_group_defaults = { 
  use_name_prefix = false
  iam_role_use_name_prefix = false
  launch_template_use_name_prefix = false
  node_security_group_use_name_prefix = false
}

eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 2

  #   k8s_labels = {
  #     role = "ops-system"
  #   }
    }

  # ops-system = {
  #   block_device_mappings = {
  #     xvda = {
  #       device_name = "/dev/xvda"
  #       ebs = {
  #         volume_size = 70
  #         volume_type = "gp3"
  #       }
  #     }
  #   }
  #   node_version = 1.26
  #   # 특정 ami 이미지 버전을 지정할수 있음.

  #   create_launch_template = true
  #   desired_size = 2,
  #   enable_bootstrap_user_data = false
  #   enable_monitoring = true
  #   instance_types = ["t3.medium"]
  #   k8s_labels = {
  #     role = "ops-system"
  #   }
  #   launch_template_os = "amazonlinux2eks"
  #   max_size = 4
  #   min_size = 2
  #   node_group_name = "ops-system"
  #   subnet_ids = ["subnet-0a9a0855c6ebf0d2e", "subnet-06c7ac8fe56c659db"]
  # },
  # ops-monitor = {
  #   block_device_mappings = {
  #     xvda = {
  #       device_name = "/dev/xvda"
  #       ebs = {
  #         volume_size = 70
  #         volume_type = "gp3"
  #       }
  #     }
  #   }
  #   node_version = 1.26
    
  #   create_launch_template = true
  #   desired_size = 1
  #   enable_bootstrap_user_data = false
  #   enable_monitoring = true
  #   instance_types = ["t3.medium"]
  #   k8s_labels = {
  #     role = "ops-monitor"
  #   }
  #   launch_template_os = "amazonlinux2eks"
  #   max_size = 1
  #   min_size = 1
  #   node_group_name = "ops-monitor"
  #   subnet_ids = ["subnet-0a9a0855c6ebf0d2e", "subnet-06c7ac8fe56c659db"]
  # }
}

cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
}

custom_network = {
  enable = true
  eniconfigs = [
    {
      name      = "ap-northeast-2a"
      subnet_id = "subnet-0bf322dee7f3f05ea"
    },
    {
      name      = "ap-northeast-2b"
      subnet_id = "subnet-0db0f92c685da47c4"
    }
  ]
}

shared_account = {
  region = "ap-northeast-2"
  # profile = ""
  # assume_role_arn = ""
}

target_account = {
  region  = "ap-northeast-1"
  # profile = ""
  # assume_role_arn = ""
}
