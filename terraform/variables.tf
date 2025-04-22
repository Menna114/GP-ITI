variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}
variable "vpc_name" {
  description = "Name of the VPC"
  default     = "vpc-devops"
  type        = string
}
variable "subnets" {
  description = "List of subnets"
  default = [
    {
      name       = "public-subnet-1"
      cidr_block = "10.0.1.0/24"
      az         = "a" 
      type       = "public"
    },
    {
      name       = "public-subnet-2"
      cidr_block = "10.0.2.0/24"
      az         = "b"  
      type       = "public"
    },
    {
      name       = "public-subnet-3"
      cidr_block = "10.0.3.0/24"
      az         = "c"  
      type       = "public"
    },
    {
      name       = "private-subnet-1"
      cidr_block = "10.0.4.0/24"
      az         = "a"  
      type       = "private"
    },
    {
      name       = "private-subnet-2"
      cidr_block = "10.0.5.0/24"
      az         = "b"  
      type       = "private"
    },
    {
      name       = "private-subnet-3"
      cidr_block = "10.0.6.0/24"
      az         = "c"  
      type       = "private"
    }
  ]
}
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}