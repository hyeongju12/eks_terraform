variable "enable_storage_class_change" {
  description = "Default Storage Class(gp2) -> gp3 Change"
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "New Storage Class Name"
  type        = string
  default     = ""
}

variable "encrypted" {
  description = "Set up volume encryption"
  type        = bool
  default     = false
}
variable "type" {
  description = "Storage Class Type"
  type        = string
  default     = ""
}
# variable "cluster_name" {
#   description = "Cluster name needed in ./scripts/network.sh"
#   type        = string
#   default     = ""
# }