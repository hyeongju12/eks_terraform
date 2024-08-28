provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
      command     = "aws"
    }
  }
}

##########################################################################################################################################################################
###############################################                       aws load balancer controller                         ###############################################
##########################################################################################################################################################################
resource "helm_release" "aws-load-balancer-controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.2"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/aws-load-balancer-controller/values.yaml", {
      cluster_name                = var.cluster_name
      vpc_id                      = var.vpc_id
      region                      = var.region
      role_arn                    = aws_iam_role.aws_load_balancer_controller[0].arn
    
      # 필요한 다른 변수들을 여기에 추가하세요
    })
  ]
    depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller]
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  name  = "aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_oidc_issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  count      = var.enable_aws_load_balancer_controller ? 1 : 0
  policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
  role       = aws_iam_role.aws_load_balancer_controller[0].name
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  count       = var.enable_aws_load_balancer_controller ? 1 : 0
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/aws-load-balancer-controller/iam_policy.json")
}
##########################################################################################################################################################################
###############################################                       aws load balancer controller                         ###############################################
##########################################################################################################################################################################



##########################################################################################################################################################################
###############################################                              aws karpenter                                 ###############################################
##########################################################################################################################################################################
resource "helm_release" "karpenter" {
  count = var.enable_aws_karpenter ? 1 : 0

  name       = "aws-karpenter"
  repository = "https://charts.karpenter.sh/"
  chart      = "karpenter"
  version    = "1.0"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/aws-load-balancer-controller/values.yaml", {
      cluster_name                = var.cluster_name
      vpc_id                      = var.vpc_id
      region                      = var.region
      role_arn                    = aws_iam_role.aws_load_balancer_controller[0].arn
      core_nodegroup_name = var.core_nodegroup_name
    
      # 필요한 다른 변수들을 여기에 추가하세요
    })
  ]
  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
    depends_on = [aws_iam_role_policy_attachment.aws_load_balancer_controller]
}


##########################################################################################################################################################################
###############################################                              aws karpenter                                 ###############################################
##########################################################################################################################################################################
data "aws_caller_identity" "current" {}