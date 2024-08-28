variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster EndPoint"
  type        = string
}

variable "cluster_certificate" {
  description = "EKS cluster Decoded Certificate data"
  type        = any  
}

variable "cluster_oidc_issuer" {
  description = "EKS cluster OIDC Issure without https://"
  type        = any  
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "enable_aws_load_balancer_controller" {
  type = bool
  default = false
}

variable "enable_aws_karpenter" {
  type = bool
  default = false
}

variable "core_nodegroup_name" {
  type = any
  description = "Core Node Group Name"
}