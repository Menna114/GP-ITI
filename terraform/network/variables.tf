variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "subnets" {
}
