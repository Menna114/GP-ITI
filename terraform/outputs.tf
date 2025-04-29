output "vpc_id" {
  description = "VPC ID from the network module"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs from the network module"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs from the network module"
  value       =    module.network.public_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID from the network module"
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID from the network module"
  value       = module.network.nat_gateway_id
}

output "nat_eip_id" {
  description = "Elastic IP ID for NAT Gateway from the network module"
  value       = module.network.nat_eip_id
}

output "private_route_table_id" {
  description = "Private route table ID from the network module"
  value       = module.network.private_route_table_id
}

output "public_route_table_id" {
  description = "Public route table ID from the network module"
  value          = module.network.public_route_table_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arn
}

output "aws_ecr_repository" {
  value = module.ecr.aws_ecr_repository
  
}
output "external_secrets_role_arn" {
  description = "IAM Role ARN for External Secrets"
  value       = module.roles.external_secrets_role_arn
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_url
  description = "The ARN of the OpenID Connect provider"
}