variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "public_subnet_az" {
  description = "Availability Zone for the public subnet"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the subnet will be created"
  type        = string
}
