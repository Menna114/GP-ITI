variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vpc-devops"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnets" {
  description = "List of subnets with CIDR, AZ, and type (public/private)"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
    type       = string
  }))
  default = [
    {
      name       = "public-subnet-1"
      cidr_block = "192.168.64.0/19"
      az         = "us-east-1a"
      type       = "public"
    },
    {
      name       = "public-subnet-2"
      cidr_block = "192.168.96.0/19"
      az         = "us-east-1b"
      type       = "public"
    },
    {
      name       = "public-subnet-3"
      cidr_block = "192.168.128.0/19"
      az         = "us-east-1c"
      type       = "public"
    },
    {
      name       = "private-subnet-1"
      cidr_block = "192.168.0.0/19"
      az         = "us-east-1a"
      type       = "private"
    },
    {
      name       = "private-subnet-2"
      cidr_block = "192.168.32.0/19"
      az         = "us-east-1b"
      type       = "private"
    },
    {
      name       = "private-subnet-3"
      cidr_block = "192.168.160.0/19"
      az         = "us-east-1c"
      type       = "private"
     }
  ]
}


variable "subnets-private" {
  description = "List of private subnets with CIDR, AZ, and type (private)"
  type = list(object({
    name       = string
    cidr_block = string
    az         = string
    type       = string
  }))
  default = [
    {
      name       = "private-subnet-1"
      cidr_block = "192.168.0.0/19"
      az         = "us-east-1a"
      type       = "private"
    },
    {
      name       = "private-subnet-2"
      cidr_block = "192.168.32.0/19"
      az         = "us-east-1b"
      type       = "private"
    },
    {
      name       = "private-subnet-3"
      cidr_block = "192.168.160.0/19"
      az         = "us-east-1c"
      type       = "private"
     }
  ]
}

variable "eks_desired_size" {
  type        = number
  default     = 3
  
}

variable "eks_max_size" {
  type        = number
  default     = 3
  
}

variable "eks_min_size" {
  type        = number
  default     = 1
 
}