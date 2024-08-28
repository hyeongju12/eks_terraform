locals {
  common_tags = { for k, v in var.common_tags : k => v if v != "" }
  cluster_addons = {
    for k, v in var.cluster_addons : k => merge(v, {
      configuration_values     = try(v.configuration_values, null) != null ? jsonencode(v.configuration_values) : null,
      service_account_role_arn = try(v.service_account_role_arn, module.irsa[k].iam_role_arn, null)
      # before_compute           = try(data.aws_eks_node_group.example != null ? v.before_compute : false, false)
    })
  }
  eks_managed_node_groups = {
    for k, v in var.eks_managed_node_groups : k => merge(v, {
      pre_bootstrap_user_data  = try(file("${path.module}/${v.pre_bootstrap_user_data}"), "")
      post_bootstrap_user_data = try(file("${path.module}/${v.post_bootstrap_user_data}"), "")
      # ami_id                    = try(info.ami_id,"ami_id",data.ami_id.default)
    })
  }
}
