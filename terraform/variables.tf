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