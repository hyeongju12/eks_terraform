<<<<<<< HEAD
# eks_terraform
=======
# Integrated Terraform module
- Integrated-Terraform 모듈의 자세한 사용 방법은 [Integrated-Terraform](#Integrated-terraform)아래 설명 및 예제 참고

##  [AWS EKS Module Documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs)
<u>Integrated-Terraform 모듈에 사용된 AWS EKS 모듈에 관한 내용들</u>
- [Frequently Asked Questions](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md)
- [Compute Resources](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/compute_resources.md)
- [IRSA Integration](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/irsa_integration.md)
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/user_data.md)
- [Network Connectivity](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md)
- Upgrade Guides
  - [Upgrade to v17.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-17.0.md)
  - [Upgrade to v18.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md)
  - [Upgrade to v19.x](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-19.0.md)

#### Reference Architecture
- **AWS EKS Module 사용법 참고 위치** \
https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples \
AWS EKS 모듈과 함께 사용할 수 있는 거의 모든 가능한 구성 및 설정을 보여주는 포괄적인 구성 모음을 제공 \
<u>그러나 이러한 예제는 프로덕션 워크로드에 일반적으로 사용되는 클러스터를 대표하지 않습니다.</u> \
AWS EKS 모듈을 활용하는 참조 아키텍처는 다음을 참조

- [EKS Reference Architecture](https://github.com/clowdhaus/eks-reference-architecture)

## [AWS EKS Terraform Module](https://github.com/terraform-aws-modules/terraform-aws-eks)

- AWS EKS Cluster Addons
- AWS EKS Identity Provider Configuration
- [AWS EKS on Outposts support](https://aws.amazon.com/blogs/aws/deploy-your-amazon-eks-clusters-locally-on-aws-outposts/)
- All [node types](https://docs.aws.amazon.com/eks/latest/userguide/eks-compute.html) are supported:
  - [EKS Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
  - [Self Managed Node Group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
  - [Fargate Profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- 카펜터 관련 AWS 인프라 리소스 생성 지원(예: IAM 역할, SQS 대기열, EventBridge 규칙 등)
- 사용자 지정 AMI, 사용자 지정 시작 템플릿, 사용자 지정 사용자 데이터 템플릿을 포함한 사용자 지정 사용자 데이터 지원
- 아마존 리눅스 2 EKS에 최적화된 AMI 및 보틀러로켓 노드 지원
- Windows 기반 노드 지원은 Windows 지원 부족 및 Windows 기반 EKS 노드 프로비저닝에 필요한 수동 단계로 인해 제공되는 기본 사용자 데이터 템플릿으로 제한됩니다.
- 모듈 생성 보안 그룹 지원, 자체 보안 그룹 가져오기, 모듈 생성 보안 그룹에 추가 보안 그룹 규칙 추가 지원
- 하위 모듈을 사용하여 클러스터와 별도로 노드 그룹/프로필 생성 지원(루트 모듈에서 사용하는 것과 동일).
- 노드 그룹/프로필 "deafult" 설정 지원 - 여러 노드 그룹/파게이트 프로필을 생성할 때 공통 구성 집합을 한 번 설정한 다음 특정 노드 그룹/프로필에서 일부 기능만 개별적으로 제어하려는 경우에 유용합니다.

### [AWS IRSA Terraform Module](https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks)
- AWS IAM 모듈의 일부
- iam-role-for-service-accounts-eks 모듈은 AWS EKS 모듈에 정의 되어 있지 않아 사용자가 따로 정의해야만 사용 가능
- [terraform-aws-iam/examples/iam-role-for-service-accounts 모듈 사용 예제](https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/modules/iam-role-for-service-accounts-eks/README.md)

일반적인 애드온/컨트롤러를 더 쉽게 배포할 수 있도록 서비스 계정에 대한 IAM 역할(IRSA) 하위 모듈이 만들어졌습니다. \
사용자가 IRSA에 필요한 페더레이션 역할 가정이 포함된 사용자 정의 IAM 역할을 만들고 애드온/컨트롤러에 필요한 관련 정책을 찾아서 작성해야 하는대신, 몇 줄의 코드만으로 IRSA 역할과 정책을 만들 수 있습니다.

현재 지원되는 애드온/컨트롤러 정책 중 일부:

- [Cert-Manager](https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-role)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/example-iam-policy.json)
- [EFS CSI Driver](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-example.json)
- [External DNS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-policy)
- [External Secrets](https://github.com/external-secrets/kubernetes-external-secrets#add-a-secret)
- [FSx for Lustre CSI Driver](https://github.com/kubernetes-sigs/aws-fsx-csi-driver/blob/master/docs/README.md)
- [Karpenter](https://github.com/aws/karpenter/blob/main/website/content/en/docs/getting-started/getting-started-with-karpenter/cloudformation.yaml)
- [Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/docs/install/iam_policy.json)
  - [Load Balancer Controller Target Group Binding Only](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#iam-permission-subset-for-those-who-use-targetgroupbinding-only-and-dont-plan-to-use-the-aws-load-balancer-controller-to-manage-security-group-rules)
- [App Mesh Controller](https://github.com/aws/aws-app-mesh-controller-for-k8s/blob/master/config/iam/controller-iam-policy.json)
  - [App Mesh Envoy Proxy](https://raw.githubusercontent.com/aws/aws-app-mesh-controller-for-k8s/master/config/iam/envoy-iam-policy.json)
- [Managed Service for Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html)
- [Node Termination Handler](https://github.com/aws/aws-node-termination-handler#5-create-an-iam-role-for-the-pods)
- [Velero](https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user)
- [VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html)

**iam-role-for-service-accounts-eks 모듈이 지원하는 정책?**
- 해당 모듈의 코드를 확인해보면 위에 지원하는 애드온/컨트롤러에 필요한 정책들이 코드에 정의 되어있고 각 변수와 매핑되어있다. <br>

>**즉, iam-role-for-service-accounts-eks 모듈을 통해 애드온/컨트롤러들에 irsa를 추가하고 싶다면?** <br>
<u>iam-role-for-service-accounts-eks module에서 지원하는 애드온/컨트롤러에 정책을 확인 후 <u>해당 기능 설정을 위한 variable만 불러와서 정의</u>하면 된다.)</u><u></u>

## AWS EKS Module Examples

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/complete): EKS Cluster using all available node group types in various combinations demonstrating many of the supported features and configurations
- [EKS Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group): EKS Cluster using EKS managed node groups
- [Fargate Profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile): EKS cluster using [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
- [Karpenter](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/karpenter): EKS Cluster with [Karpenter](https://karpenter.sh/) provisioned for intelligent data plane management
- [Outposts](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/outposts): EKS local cluster provisioned on [AWS Outposts](https://docs.aws.amazon.com/eks/latest/userguide/eks-outposts.html)
- [Self Managed Node Group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group): EKS Cluster using self-managed node groups
- [User Data](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/user_data): Various supported methods of providing necessary bootstrap scripts and configuration settings via user data


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# Integrated-Terraform
## 설명
Integrated-Terraform 은 eks의 손쉬운 설치 및 운영을 목적으로 [terraform-aws-eks 모듈](#https://github.com/terraform-aws-modules/terraform-aws-eks) 기반으로 개발되었다. \
terraform-aws-eks 모듈에 정의된 많은 설정 중 필요한 기능이 있을 경우 기능 추가를 위해 해당 모듈에 정의된 variable을 확인하여 값을 대입하는 형태

<details ><summary>🛠Integrated-Terraform 이 제공하는 주요 기능은 다음과 같다:
</summary>

1. EKS cluster 생명주기 관리
2. EKS nodegroup 생명주기 관리
3. [custom network 지원](#use"-"instead-of-spacing-words)
4. [AWS 교차 계정 배포 지원](#example)
    - [❓ EASYME.md가 뭐예요?](#-easymemd가-뭐예요)
    - [🛠 기능 엿보기](#-기능-엿보기)
</details>

## 사용법

```hcl
project    = "IO"
env        = "DEV"
org        = "PSA"
region     = "ap-southeast-1"
vpc_id     = "vpc-074d66a8e509cd510"
subnet_ids = ["subnet-016244d5c89407c96", "subnet-04eb268f5f26012d3"]

# control plane subnet
# control plane subnet과 data plane subnet을 분리하면 좋은 점
# https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network_reqs.html
control_plane_subnet_ids = ["subnet-0b600a3577582f6d4", "subnet-0af56d7c3e33cd19f"]
cluster_name             = "test-eks"
cluster_version          = 1.27

# cluster private , public endpoints
cluster_endpoint_public_access  = true # -> Default = False
cluster_endpoint_private_access = true # -> Default = True

#node sg recommended rules(옵션)
node_security_group_enable_recommended_rules = true
node_security_group_use_name_prefix          = false
# 접두사로 IAM 역할 이름(iam_role_name)을 사용할지 여부를 결정
iam_role_use_name_prefix = false
iam_role_name            = "PSA-DEV-IAMROLE-EKS"

cluster_encryption_policy_use_name_prefix = false

cluster_security_group_use_name_prefix = false
cluster_security_group_name            = "PSA-DEV-IO-SG-EKS-AP2"

cluster_security_group_additional_rules = {
  cluster_egress_all = {
    cidr_blocks = ["0.0.0.0/0"]
    description = "cluster all egress"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    type        = "egress"
  },
  ingress_nodes_ports_tcp = {
    description                = "To node 1025-65535"
    from_port                  = 1025
    protocol                   = "tcp"
    source_node_security_group = true
    to_port                    = 65535
    type                       = "ingress"
  }
  # ... Cluster와 매핑 할 Security Groups 추가
}

#eks noodegroups 공용 변수
eks_managed_node_group_defaults = {
  # nodegroup
  subnet_ids      = [] # Input Subnet ID
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
  iam_role_use_name_prefix = false
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
eks_managed_node_groups = {
  ops-system = {
    create               = true
    launch_template_name = "ops-system"
    instance_types       = ["t3.large"]
    # ami_id의 경우 EKS 수동 업그레이드를 위한 필수 valiable
    ami_id       = "ami-003744174fb66a37e"
    desired_size = 1
    max_size     = 3
    min_size     = 1
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
      role = "test"
    }
    tags = {
      Name = "test"
    }
  }
}

cluster_addons = {
  aws-ebs-csi-driver = {
    # addon_version = "v1.26.0-eksbuild.1" # Cluster Addon Version Fix시 사용
    most_recent = true
  }
  aws-efs-csi-driver = {
    # addon_version = "v1.7.1-eksbuild.1"
    most_recent = true
  }
  coredns = {
    # addon_version = "v1.9.3-eksbuild.2"
    most_recent = true
  }
  kube-proxy = {
    # addon_version = "v1.26.2-eksbuild.1"
    most_recent = true
  }
  vpc-cni = {
    # addon_version  = "v1.12.5-eksbuild.2"
    most_recent    = true
    before_compute = false
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
}
cluster_addons_irsa = {
  vpc-cni = {
    role_name             = "PSA-DEV-IO-IAMROL-EKS-ADD-CNI-AP2"
    vpc_cni_enable_ipv4   = true
    attach_vpc_cni_policy = true
    oidc_providers = {
      ex = {
        namespace_service_accounts = ["kube-system:aws-node"]
      }
    }
  }
  aws-ebs-csi-driver = {
    role_name             = "PSA-DEV-IO-IAMROL-EKS-ADD-EBS-AP2"
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
      name      = "ap-southeast-1a"          # 신규 서브넷이 위치한 가용영역
      subnet_id = "subnet-0204ec82a2611b481" # 신규 서브넷 id
    },
    {
      name      = "ap-southeast-1c"          # 신규 서브넷이 위치한 가용영역
      subnet_id = "subnet-0b3439cb0964264a7" # 신규 서브넷 id
    }
  ]
}
change_storage_class = {
  enable             = true
  type               = "gp3"
  storage_class_name = "ebs-gp3"
  encrypted          = false
}
shared_account = {
  region  = "ap-southeast-1"
  profile = "default"
  # assume_role_arn = ""
}

target_account = {
  region  = "ap-southeast-1"
  profile = ""
  # assume_role_arn = ""
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.57 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.57 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="terraform-aws-modules/eks/aws"></a> [eks](#module\_eks) | [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.20.0) | 19.20.0 |
| <a name="irsa"></a> [irsa](#module\_irsa) | [terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks](https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks) | 5.33.1 |
| <a name="module_change_storage_class"></a> [change\_storage\_class](#module\_change\_storage\_class) | ./modules/change_storage_class | n/a |
| <a name="module_custom_network"></a> [custom\_network](#module\_custom\_network) | ./modules/custom_network | n/a |

terraform-aws-modules/eks/aws
## Resources

| Name | Type |
|------|------|
| aws_ami.eks_opt | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | `{}` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `true` | **yes** |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `false` | **yes** |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `""` | **yes** |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source | `any` | `{}` | **yes** |
| <a name="input_cluster_security_group_description"></a> [cluster\_security\_group\_description](#input\_cluster\_security\_group\_description) | Description of the cluster security group created | `string` | `"EKS cluster security group"` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Name to use on cluster security group created | `string` | `null` | no |
| <a name="input_cluster_security_group_tags"></a> [cluster\_security\_group\_tags](#input\_cluster\_security\_group\_tags) | A map of additional tags to add to the cluster security group created | `map(string)` | `{}` | **yes** |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster | `map(string)` | `{}` | no |
| <a name="input_cluster_encryption_policy_use_name_prefix"></a> [cluster\_encryption\_policy\_use\_name\_prefix](#input\_cluster\_encryption\_policy\_use\_name\_prefix) | Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix | `bool` | `true` | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`) | `string` | `null` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane | `list(string)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if EKS resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_aws_auth_configmap"></a> [create\_aws\_auth\_configmap](#input\_create\_aws\_auth\_configmap) | Determines whether to create the aws-auth configmap. NOTE - this is only intended for scenarios where the configmap does not exist (i.e. - when using only self-managed node groups). Most users should use `manage_aws_auth_configmap` | `bool` | `false` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Determines if a security group is created for the cluster. Note: the EKS service creates a primary security group for the cluster by default | `bool` | `true` | no |
| <a name="input_create_node_security_group"></a> [create\_node\_security\_group](#input\_create\_node\_security\_group) | Determines whether to create a security group for the node groups or use the existing `node_security_group_id` | `bool` | `true` | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of EKS managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | `{}` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false` | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | **yes** |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Cluster IAM role path | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_manage_aws_auth_configmap"></a> [manage\_aws\_auth\_configmap](#input\_manage\_aws\_auth\_configmap) | Determines whether to manage the aws-auth configmap | `bool` | `false` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source | `any` | `{}` | no |
| <a name="input_node_security_group_description"></a> [node\_security\_group\_description](#input\_node\_security\_group\_description) | Description of the node security group created | `string` | `"EKS node shared security group"` | no |
| <a name="input_node_security_group_enable_recommended_rules"></a> [node\_security\_group\_enable\_recommended\_rules](#input\_node\_security\_group\_enable\_recommended\_rules) | Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic | `bool` | `true` | no |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | ID of an existing security group to attach to the node groups created | `string` | `""` | no |
| <a name="input_node_security_group_name"></a> [node\_security\_group\_name](#input\_node\_security\_group\_name) | Name to use on node security group created | `string` | `null` | no |
| <a name="input_node_security_group_tags"></a> [node\_security\_group\_tags](#input\_node\_security\_group\_tags) | A map of additional tags to add to the node security group created | `map(string)` | `{}` | no |
| <a name="input_node_security_group_use_name_prefix"></a> [node\_security\_group\_use\_name\_prefix](#input\_node\_security\_group\_use\_name\_prefix) | Determines whether node security group name (`node_security_group_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets | `list(string)` | `[]` | **yes** |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster security group will be provisioned | `string` | `null` | **yes** |


## Outputs
| Name | Description | Example |
|------|------------|------------------------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_aws\_auth\_configmap\_yaml) | kubeconfig update 명령어 출력 | <pre>configure_kubectl = "aws eks --region **REGION** update-kubeconfig --name **ClUSTER_NAME**</pre>
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_aws\_auth\_configmap\_yaml) | `var.cluster_version`에 정의된 cluster version에 따라 cluster addons의 버전 출력 | <pre>cluster_addons = {<br>  kube-proxy = {<br>    addon_version    = "v1.27.6-eksbuild.2"<br>  }<br>  vpc-cni = {<br>    addon_version = "v1.15.1-eksbuild.1"<br>  }<br>  ...<br>}</pre>
| <a name="output_ami_id"></a> [ami\_id](#output\_aws\_auth\_configmap\_yaml) | kubeconfig update 명령어 출력 | <pre>configure_kubectl = "aws eks --region **REGION** update-kubeconfig --name **ClUSTER_NAME**</pre>

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
>>>>>>> 2018422 (First Commit)
