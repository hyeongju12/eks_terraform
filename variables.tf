variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
  default     = null
}
variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
  default     = []
}
variable "cluster_name" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = null
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`)"
  type        = string
  default     = null
}
variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}
variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}
variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}
variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}
variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}
variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}
variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}
variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = false
}

variable "cluster_encryption_policy_use_name_prefix" {
  description = "Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "cluster_encryption_policy_name" {
  description = "Name to use on cluster encryption policy created"
  type        = string
  default     = null
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created"
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix"
  type        = bool
  default     = false
}

variable "node_security_group_name" {
  description = "Name to use on node security group created"
  type        = string
  default     = null
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}
variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created"
  type        = string
  default     = ""
}
variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created"
  type        = map(string)
  default     = {}
}
variable "node_security_group_description" {
  description = "Description of the node security group created"
  type        = string
  default     = "EKS node shared security group"
}
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}
variable "node_security_group_enable_recommended_rules" {
  description = "Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic"
  type        = bool
  default     = true
}
variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
  default     = []
}
# Custom Variable
variable "project" {
  type        = string
  default     = ""
  description = "project code or corporate code"
}
variable "region" {
  type        = string
  default     = ""
  description = "aws region e.g. ap-northeast-2"
}
variable "env" {
  type        = string
  default     = ""
  description = "environment: dev, stg, qa, prod "
}
variable "org" {
  type        = string
  default     = ""
  description = "organization name"
}
variable "shared_account" {
  type = object({
    region          = optional(string, "")
    profile         = optional(string, "")
    assume_role_arn = optional(string, "")
  })
  default     = {}
  description = "default account"
}

variable "target_account" {
  type = object({
    region          = optional(string, "")
    profile         = optional(string, "")
    assume_role_arn = optional(string, "")
  })
  default     = {}
  description = "target account"
}

variable "custom_network" {
  type = object({
    enable                             = optional(bool, false)
    nodegroups_create_duration_seconds = optional(string, "")
    eniconfigs = optional(list(object({
      name      = string
      subnet_id = string
    })), [])
  })
  default     = {}
  description = "If set to true. The AWS CNI(aws-node DaemonSet) uses a custom network."
}
variable "nodegroup_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed nodegroup(s), self-managed nodegroup(s), Fargate profile(s))"
  type        = string
  default     = "30s"
}

variable "cluster_addons_irsa" {
  description = "sfwfs"
  type        = any
  default     = {}
}

variable "change_storage_class" {
  type = object({
    enable             = optional(bool, false)
    type               = optional(string, "")
    storage_class_name = optional(string, "")
    encrypted          = optional(bool, false)
  })
  default     = {}
  description = "Change Storage Class change config"
}
variable "common_tags" {
  type = object({
    env        = optional(string, "")
    project    = optional(string, "")
    org        = optional(string, "")
    region     = optional(string, "")
    managed_by = optional(string, "terraform")
  })
  default     = {}
  description = "common tags"
}

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = false
}

variable "enable_aws_karpenter" {
  type    = bool
  default = false
}

variable "enable_ingress_nginx" {
  type    = bool
  default = false
}

variable "enable_argocd" {
  type    = bool
  default = false
}