# # HELM Provider
# provider "helm" {
#     kubernetes {
#         host                   = aws_eks_cluster.aws_eks.cluster_endpoint
#         cluster_ca_certificate = base64decode(aws_eks_cluster.aws_eks.cluster_certificate_authority_data)
#         token                  = aws_eks_cluster.aws_eks.token
#     }
# }