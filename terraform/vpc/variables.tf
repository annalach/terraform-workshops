variable "vpc_cidr_block" {
  description = "The VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr_blocks" {
  description = "Public subnets cidr blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr_blocks" {
  description = "Private subnets cidr blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}
