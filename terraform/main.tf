module "network" {
  source   = "./network"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  region   = var.region
  azs      = var.azs
  subnets  = var.subnets
}
