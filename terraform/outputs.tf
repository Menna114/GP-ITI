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
  value       = module.network.public_subnet_ids
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
