variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}
variable "public_subnet_az" {
  description = "Availability Zone for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "private_subnet_az" {
  description = "Availability Zone for the private subnet"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to be used for SSH access"
  type        = string
  default     = "Terraform-Project" # Change this to your actual key pair name
}
 
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}
variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro" # Change this to your desired instance type
}
variable "public_sg_id" {
  description = "Security Group ID for the public EC2 instance"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where the EC2 instance will be launched"
  type        = string
}
