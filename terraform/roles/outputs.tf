output "external_secrets_role_arn" {
  description = "IAM Role ARN for External Secrets"
  value       = aws_iam_role.external_secrets_role.arn
}
