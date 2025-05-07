data "aws_caller_identity" "current" {}

data "tls_certificate" "eks" {
  url = var.eks_oidc_provider_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = var.eks_oidc_provider_url
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "ebs_csi" {
  name = "eks-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:aud" : "sts.amazonaws.com",
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  policy_arn = data.aws_iam_policy.ebs_csi_policy.arn
  role       = aws_iam_role.ebs_csi.name
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.29.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi.arn
  depends_on               = [var.node_group_depends_on]
}

######################################################
resource "aws_iam_policy" "ecr_access" {
  name        = "ECRAccessPolicy"
  description = "Policy to allow ECR access for ArgoCD Image Updater"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
          "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ],
        Resource = "arn:aws:ecr:us-east-1:661013218527:repository/node-app-jenkins2"
      }
    ]
  })
}


resource "aws_iam_role" "argocd_ecr_role" {
  name = "argocd-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:argocd:argo-image-updater"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecr_access_attach" {
  role       = aws_iam_role.argocd_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}





resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/aws-load-balancer-controller-policy.json")


}


resource "aws_iam_role" "aws_lb_controller_role" {
  name = "aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

resource "aws_iam_policy" "alb_acm_policy" {
  name        = "AWSALBACMPolicy"
  description = "Policy for ALB to access ACM for SSL certificates"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          
        "sts:AssumeRoleWithWebIdentity",
        "acm:ListCertificates",
        "elbv2:DescribeLoadBalancers",
        "elbv2:DescribeTargetGroups",
        "elbv2:DescribeListeners",
        "elbv2:DescribeListenerCertificates",
        "acm:DescribeCertificate"
        ]
        Resource  = "*"
      },
      {
        Effect    = "Allow"
        Action    = [
          "sts:AssumeRoleWithWebIdentity"
        ]
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_acm_policy_attach" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.alb_acm_policy.arn
}
