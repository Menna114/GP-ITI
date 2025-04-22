resource "aws_vpc" "vpc-devops" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}