module "network" {
  source   = "./network"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  region   = var.region
  azs      = var.azs
  subnets  = var.subnets
}

module "eks" {
  source       = "./eks"
  subnets      = module.network.private_subnet_ids
  desired_size = var.eks_desired_size
  max_size     = var.eks_max_size
  min_size     = var.eks_min_size
}

module "ebs" {
  source                 = "./ebs"
  eks_cluster_name       = module.eks.cluster_name
  eks_oidc_provider_url  = module.eks.oidc_provider_url
  node_group_depends_on  = module.eks.node_group_arn
}
