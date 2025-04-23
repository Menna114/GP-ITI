# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     =  my_eks
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = var.subnet_ids   # hatghar hasb el private beta3 engy
    endpoint_private_access = true
    endpoint_public_access  =  true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
}


#roles
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# attach role (This policy provides Kubernetes the permissions it requires to manage resources on your behalf)
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
} 

 
# node group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn

  subnet_ids      = var.subnet_ids    #hatghar hasb el private beta3 engy
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
}

# role for  worker node 
resource "aws_iam_role" "eks_nodes_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {   # 3ashan akhle pods el gwa worker node te3raf tekon 3ala nafs network el vpc 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_readonly" {  # 3ashan eks ye3raf yeshghl app mn image tb hya fen w yeshof docker image mn registry da 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

 
 
 