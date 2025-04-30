data "tls_certificate" "eks" {
  url = var.eks_oidc_provider_url
}

resource "aws_iam_role" "external_secrets_role" {
  name = "external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.eks_oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:default:external-secrets-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "external_secrets_policy" {
  name        = "external-secrets-policy"
  description = "Allow External Secrets Operator to access Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_attach" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
