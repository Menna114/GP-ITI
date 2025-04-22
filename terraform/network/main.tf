resource "aws_vpc" "vpc-devops" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "public" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.type == "public" }

  vpc_id                  = aws_vpc.vpc-devops.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${each.value.az}"
  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}

resource "aws_subnet" "private" {
  for_each = { for subnet in var.subnets : subnet.name => subnet if subnet.type == "private" }

  vpc_id                  = aws_vpc.vpc-devops.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}${each.value.az}"
  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}