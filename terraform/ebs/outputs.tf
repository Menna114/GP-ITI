output "ebs_csi_role_arn" {
  value       = aws_iam_role.ebs_csi.arn
  description = "EBS CSI IAM role ARN"
}
