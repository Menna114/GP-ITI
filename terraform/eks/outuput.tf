output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "node_group_arn" {
  value = aws_eks_node_group.node_group.arn
}

output "oidc_provider_url" {
  value = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

