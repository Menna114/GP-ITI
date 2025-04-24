variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "node_group_depends_on" {
  description = "Dependency reference to EKS node group"
  type        = any
}
