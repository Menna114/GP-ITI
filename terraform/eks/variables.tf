 variable "desired_size" {
  type        = number
  default     = 3
 
}

variable "max_size" {
  type        = number
  default     = 3
  
}

variable "min_size" {
  type        = number
  default     = 1
   
}

variable "subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}
