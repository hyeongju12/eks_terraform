variable "use_custom_network" {
  description = "Bool of Whether to use custom network"
  type        = bool
  default     = false
}

variable "eni_configs" {
  description = "CRD VPC CNI Eniconfig manifest modification information (subnet id, availability zone)"
  type        = list(any)
  default     = []
  sensitive   = true
}

variable "nodegroups_create_duration_seconds" {
  description = "EKS Managed nodegroup creation latency after VPC CNI EniConfig"
  type        = string
  default     = "30s"
}
variable "nodegroups_create_trigger" {
  description = "Map of EKS managed node group Pass it to the EKS module "
  type        = any
  default     = {}
}
variable "cluster_name" {
  description = "Cluster name needed in ./scripts/network.sh"
  type        = string
  default     = ""
  sensitive   = true
}
variable "cluster_sg" {
  description = "Cluster security group id required for ./scripts/network.sh"
  type        = string
  default     = ""
  sensitive   = true
}
variable "node_sg" {
  description = "Node security group id required for ./scripts/network.sh"
  type        = string
  default     = ""
  sensitive   = true
}
