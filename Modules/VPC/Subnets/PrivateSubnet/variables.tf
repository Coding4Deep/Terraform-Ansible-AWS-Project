variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}
variable "vpc_id" {
  description = "ID of the VPC where the private subnet will be created"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the private subnet"
  type        = string
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID to associate with the NAT Gateway"
}