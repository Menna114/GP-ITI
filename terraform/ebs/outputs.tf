output "ebs_csi_role_arn" {
  value       = aws_iam_role.ebs_csi.arn
  description = "EBS CSI IAM role ARN"
}


output "eks_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
  description = "The ARN of the OpenID Connect provider"
}