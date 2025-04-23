output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc-devops.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [for subnet in values(aws_subnet.private) : subnet.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.vpc-igw.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.k8s-nat.id
}

output "nat_eip_id" {
  description = "The ID of the Elastic IP for the NAT Gateway"
  value       = aws_eip.nat.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}
