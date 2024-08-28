data "aws_availability_zones" "available" {}
data "aws_eks_addon_version" "this" {
  for_each           = { for k, v in local.cluster_addons : k => v }
  addon_name         = (each.key)
  kubernetes_version = var.cluster_version
  # try(each.value.name, each.key)
}
# data "aws_eks_node_group" "example" {
#   for_each        = { for k, v in var.eks_managed_node_groups : k => v }
#   cluster_name    = var.cluster_name
#   node_group_name = (each.key)
#   depends_on      = [module.eks]
# }

data "aws_ami_ids" "eks_opt" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}
# data "utils_aws_eks_update_kubeconfig" "test" {
#   conut        = var.enable_auto_update_kubeconfig ? 1 : 0
#   profile      = local.profile
#   cluster_name = var.cluster_name
#   # kubeconfig   =
# }
