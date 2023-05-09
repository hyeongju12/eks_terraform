# provider "kubernetes" {
#     config_path = "~/.kube/config"
# }

# resource "kubernetes_secret" "autoscaler_secret" {
#     metadata {
#         name = "autoscaler-aws-cluster-autoscaler"
#     }

#     data = {
#         AwsAccessKey = "AKIA27ACABPS77UN7QP3"
#         AwsSecretAccessKey = "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"
#     }
# }