
#------------------------------ public
module "eks" {
  source                   = "terraform-aws-modules/eks/aws"
  version                  = "20.22.0"
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  cluster_name             = var.cluster_name
  cluster_version          = var.cluster_version
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # access points setting -> deafult(false)
  cluster_endpoint_public_access          = var.cluster_endpoint_public_access
  cluster_endpoint_private_access         = var.cluster_endpoint_private_access
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  node_security_group_name                     = var.node_security_group_name
  node_security_group_use_name_prefix          = var.node_security_group_use_name_prefix
  node_security_group_tags                     = var.node_security_group_tags
  node_security_group_enable_recommended_rules = var.node_security_group_enable_recommended_rules

  # node_security_group_description = var.node_security_group_description
  node_security_group_additional_rules = var.node_security_group_additional_rules

  #--- 필수Addons
  cluster_addons = local.cluster_addons

  cluster_security_group_name            = var.cluster_security_group_name
  cluster_security_group_use_name_prefix = var.cluster_security_group_use_name_prefix
  iam_role_use_name_prefix               = var.iam_role_use_name_prefix
  iam_role_name                          = var.iam_role_name

  cluster_encryption_policy_use_name_prefix = var.cluster_encryption_policy_use_name_prefix

  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_groups = try(
    module.custom_network.trigger_eks_managed_nodegroups,
    var.eks_managed_node_groups
  )
  enable_cluster_creator_admin_permissions = true

  tags = merge(var.cluster_tags, local.common_tags, {
    region = var.region
  })
  providers = {
    aws = aws.TARGET
  }
}

### IRSA(IAM role for service accounts) ###
module "irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  for_each = {
    for k, v in var.cluster_addons_irsa : k => v
    if var.cluster_addons_irsa != {}
  }
  # role_name             = lookup(each.value, "role_name", each.key)
  role_name             = each.value.role_name
  attach_ebs_csi_policy = try(each.value.attach_ebs_csi_policy, false)
  attach_vpc_cni_policy = try(each.value.attach_vpc_cni_policy, false)
  vpc_cni_enable_ipv4   = try(each.value.vpc_cni_enable_ipv4, false)
  role_policy_arns      = try(each.value.role_policy_arns, {})
  oidc_providers = { for key, info in each.value.oidc_providers : key => merge({
    provider_arn = module.eks.oidc_provider_arn }, info)
  }
  tags = try(each.value.tags, local.common_tags)
  providers = {
    aws = aws.TARGET
  }
}

# Custom Netwoking
module "custom_network" {
  source                             = "./modules/custom_network"
  count                              = var.custom_network.enable ? 1 : 0
  use_custom_network                 = var.custom_network.enable
  eni_configs                        = var.custom_network.eniconfigs
  nodegroups_create_duration_seconds = var.custom_network.nodegroups_create_duration_seconds
  nodegroups_create_trigger          = var.eks_managed_node_groups

  cluster_name = module.eks.cluster_name
  cluster_sg   = module.eks.cluster_primary_security_group_id
  node_sg      = module.eks.node_security_group_id

  providers = {
    aws = aws.TARGET
  }
}
module "change_storage_class" {
  source             = "./modules/change_storage_class"
  count              = var.change_storage_class.enable ? 1 : 0
  type               = var.change_storage_class.type
  storage_class_name = var.change_storage_class.storage_class_name
  encrypted          = var.change_storage_class.encrypted
  depends_on = [
    module.eks.cluster_addons
  ]
}

module "custom_addons" {
  source = "./modules/custom_addons"

  cluster_name        = var.cluster_name
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  cluster_oidc_issuer = module.eks.oidc_provider
  region              = var.region
  vpc_id              = var.vpc_id
  core_nodegroup_name = var.eks_managed_node_groups["core-nodes"]["name"]
  load_balancer_sg_ids = aws_security_group.lb-sg.id

  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_aws_karpenter                = var.enable_aws_karpenter
  enable_ingress_nginx                = var.enable_ingress_nginx
  enable_argocd                       = var.enable_argocd
}

resource "aws_security_group" "lb-sg" {
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}