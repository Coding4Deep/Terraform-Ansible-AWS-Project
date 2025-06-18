variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "public_sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "key_content" {
  type        = string
  description = "The content of the private key in PEM format"
  sensitive   = true
}