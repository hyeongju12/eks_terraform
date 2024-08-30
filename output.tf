output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}
output "cluster_addons" {
  value = { for k, v in data.aws_eks_addon_version.this : k => {
    addon_version = v.version
    }
  }
}
output "ami_id" {
  value = data.aws_ami_ids.eks_opt.ids
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "custom_addons_cluster_endpoint" {
  value = module.custom_addons.cluster_endpoint
}