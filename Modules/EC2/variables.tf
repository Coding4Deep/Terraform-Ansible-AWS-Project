variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  type        = string

}

variable "instance_type" {
  description = "Type of EC2 instance to launch"
  type        = string
  default     = "t2.micro" # Default instance type, can be overridden
}
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}
variable "public_subnet_id" {
  description = "ID of the public subnet where the EC2 instance will be launched"
  type        = string
}

variable "public_sg_id" {
  description = "Security Group ID for the public EC2 instance"
  type        = string
}