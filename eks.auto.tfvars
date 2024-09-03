common_tags = {
  env = "dev"
  org = "ctc"
}

region     = "ap-northeast-1"
vpc_id     = "vpc-00ca7a771aad20fb4"
subnet_ids = ["subnet-0c3902566337798fa", "subnet-0582414a307425d7c", "subnet-0b0fea94c0ef70ef1"]

# control plane subnet
# control plane subnet과 data plane subnet을 분리하면 좋은 점
# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network_reqs.html
control_plane_subnet_ids = ["subnet-0c3902566337798fa", "subnet-0582414a307425d7c", "subnet-0b0fea94c0ef70ef1"]
cluster_name             = "test-eks-1"
cluster_version          = "1.30"

# cluster private , public endpoints
cluster_endpoint_public_access  = true # -> Default = False
cluster_endpoint_private_access = true # -> Default = True

#node sg recommended rules(옵션)
node_security_group_enable_recommended_rules = true
node_security_group_use_name_prefix          = false
# 접두사로 IAM 역할 이름(iam_role_name)을 사용할지 여부를 결정
iam_role_use_name_prefix = false
iam_role_name            = "CTC-DEV-IAMROLE-EKS"

cluster_encryption_policy_use_name_prefix = false

cluster_security_group_use_name_prefix = false
cluster_security_group_name            = "CTC-DEV-IO-SG-EKS-AP1"

cluster_security_group_additional_rules = {
  cluster_egress_all = {
    cidr_blocks = ["0.0.0.0/0"]
    source_cluster_security_group = true
    description = "cluster all egress"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    type        = "egress"
  },
  cluster_ingress_all = {
    cidr_blocks = ["0.0.0.0/0"]
    source_cluster_security_group = true
    description = "cluster all egress"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    type        = "ingress"
  },
  # ingress_nodes_ports_tcp = {
  #   description                = "To node 1025-65535"
  #   from_port                  = 1025
  #   protocol                   = "tcp"
  #   source_node_security_group = true
  #   to_port                    = 65535
  #   type                       = "ingress"
  # },
  # bastion_sg = {
  #   description = "bastion"
  #   protocol    = "tcp"
  #   from_port   = 443
  #   to_port     = 443
  #   type        = "ingress"
  #   cidr_blocks = ["10.0.0.0/16"]
  # }
  # karpenter_webhook = {
  #   description                = "Karpenter webhook"
  #   protocol                   = "tcp"
  #   from_port                  = 8443
  #   to_port                    = 8443
  #   type                       = "ingress"
  #   source_node_security_group = true
  # }
}



#eks noodegroups 공용 변수
eks_managed_node_group_defaults = {
  # nodegroup
  subnet_ids      = ["subnet-0c3902566337798fa", "subnet-0582414a307425d7c", "subnet-0b0fea94c0ef70ef1"]
  use_name_prefix = false

  # user_data
  #  *AMI를 지정할 때 Amazon EKS는 사용자 데이터를 병합하지 않습니다.
  #  => ami_id 인수 사용시 사용자 데이터 병합을 위해 enable_bootstrap_user_datauser_data 인수를 true로 설정해야 합니다.
  #  https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
  platform                   = "linux"
  enable_bootstrap_user_data = true

  # launch_template
  create_launch_template          = true
  use_custom_launch_template      = true
  ebs_optimized                   = true
  enable_monitoring               = true
  launch_template_use_name_prefix = false

  # iam_role
  create_iam_role            = true
  iam_role_name              = "EKS-NoddeGroup-Role"
  iam_role_attach_cni_policy = true
  iam_role_use_name_prefix   = false
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }
}
eks_managed_node_groups = {
  core-nodes = {
    name                 = "core-nodes"
    create               = true
    # launch_template_name = "core-nodes-tpl"
    instance_types       = ["t3.2xlarge"]
    ami_id               = "ami-0b42fa8b1839302ca"
    desired_size         = 2
    max_size             = 3
    min_size             = 1
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
        }
      }
    }
    labels = {
      role = "core-nodes"
    }
    tags = {
      Name = "core-nodes"
    }
  }
}

node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
}

cluster_addons = {
  aws-ebs-csi-driver = {
    addon_version               = "v1.33.0-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
  }
  coredns = {
    addon_version               = "v1.11.1-eksbuild.8"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
  }
  kube-proxy = {
    addon_version     = "v1.30.0-eksbuild.3"
    resolve_conflicts = "OVERWRITE"
    most_recent       = true
  }
  vpc-cni = {
    addon_version               = "v1.18.3-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
    before_compute              = false
    # configuration_values = {
    #   env = {
    #     # Reference https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking
    #     AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
    #     ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"

    #     # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    #     ENABLE_PREFIX_DELEGATION = "true"
    #     WARM_PREFIX_TARGET       = "1"
    #   }
    # }
  }
  aws-mountpoint-s3-csi-driver = {
    addon_version               = "v1.7.0-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true

  }
  aws-efs-csi-driver = {
    addon_version               = "v2.0.6-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
  }
  eks-pod-identity-agent = {
    addon_version               = "v1.3.0-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    most_recent                 = true
  }
}
cluster_addons_irsa = {
  vpc-cni = {
    role_name             = "CTC-DEV-IO-IAMROL-EKS-ADD-CNI-AP1"
    vpc_cni_enable_ipv4   = true
    attach_vpc_cni_policy = true
    oidc_providers = {
      ex = {
        namespace_service_accounts = ["kube-system:aws-node"]
      }
    }
  }
  aws-ebs-csi-driver = {
    role_name             = "CTC-DEV-IO-IAMROL-EKS-ADD-EBS-AP1"
    attach_ebs_csi_policy = true
    oidc_providers = {
      ex = {
        namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
      }
    }
  }
  # aws-efs-csi-driver = {
  #   role_name             = "PSA-DEV-IO-IAMROL-EKS-ADD-EFS-AP2"
  #   attach_efs_csi_policy = true
  #   oidc_providers = {
  #     controller = {
  #       namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
  #     }
  #     node = {
  #       namespace_service_accounts = ["kube-system:efs-csi-node-sa"]
  #     }
  #   }
  # }
  # aws-load-balancer-controller = {
  #   role_name                              = "PSA-DEV-IO-IAMROL-EKS-ADD-ALB-AP2"
  #   attach_load_balancer_controller_policy = true
  #   oidc_providers = {
  #     controller = {
  #       namespace_service_accounts = ["kube-system:aws-load-balancer-controller-sa"]
  #     }
  #   }
  # }
}

# custom network 설정
# 절차는 psa_tf -> custom network와 동일
# 조건 : ->
# Node를 위치시킬 서브넷과 별개로 추가적인 서브넷 생성이 필요합니다..
# Custom Network를 위해 신규로 생성하는 서브넷의 가용영역은 Node를 배포할(또는 배포한) 서브넷의 가용영역과 동일해야 합니다.

# 배포 방법
# custom_network.enable = true 설정
# custom_network.eniconfigs = [{ name = $AZ } , { subnet_id = $SUBNET_ID }] 입력
custom_network = {
  enable                             = false
  nodegroups_create_duration_seconds = "50s"
  eniconfigs = [
    {
      name      = "ap-southeast-1a"
      subnet_id = "subnet-0204ec82a2611b481"
    },
    {
      name      = "ap-southeast-1"
      subnet_id = "subnet-0b3439cb0964264a7"
    }
  ]
}
change_storage_class = {
  enable             = true
  type               = "gp3"
  storage_class_name = "gp3"
  encrypted          = false
}
shared_account = {
  region  = "ap-northeast-1"
  profile = "default"
  # assume_role_arn = ""
}
target_account = {
  region  = "ap-northeast-1"
  profile = ""
  # assume_role_arn = ""
}


enable_aws_load_balancer_controller = true
enable_aws_karpenter                = true