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
  subnet_ids   = module.network.private_subnet_ids #subnet beta3tkm 
  desired_size = var.eks_desired_size
  max_size     = var.eks_max_size
  min_size     = var.eks_min_size
}