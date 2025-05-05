resource "aws_vpc" "vpc-devops" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.vpc-devops.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if subnet.type == "public"
  }

  vpc_id                  = aws_vpc.vpc-devops.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone       = each.value.az

  tags = {
    Name = each.value.name
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
    if subnet.type == "private"
  }

  vpc_id                  = aws_vpc.vpc-devops.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false
  availability_zone       = each.value.az

  tags = {
    Name = each.value.name
    Type = "private"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "k8s-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  depends_on = [aws_internet_gateway.vpc-igw]

  tags = {
    Name = "k8s-nat"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-devops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-igw.id
  }

  tags = {
    Name = "public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc-devops.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s-nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
