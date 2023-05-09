output "cluster_name" {
    value = aws_eks_cluster.aws_eks.name
    description = "EKS cluster name"
}

output "cluster_arn" {
    value = aws_iam_role.eks_cluster.arn
    description = "cluster arn role"
}

# output "cluster_oidc_url" {
#     value = aws_eks_cluster.aws_eks.identity.cluster_oidc_url
#     description = "cluster oidc url"
# }