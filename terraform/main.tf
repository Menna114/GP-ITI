module "network" {
    source = "./network"
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
    subnets = var.subnets
    region = var.region
}