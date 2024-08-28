# output "use_custom_network" {
#   description = "Bool of Whether to use custom network"
#   value       = var.use_custom_network
# }

# output "eni_configs" {
#   description = "CRD VPC CNI Eniconfig"
#   value       = var.eni_configs
# }
# output "trigger_eks_managed_nodegroups" {
#   description = "valiable eks_nodegroups triggers"
#   value       = jsondecode(time_sleep.this[0].triggers["eks_managed_nodegroups"])
# }