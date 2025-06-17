variable "private_instances" {
  type = map(object({
    ami           = string
    instance_type = string
  }))
}

variable "private_subnet_id" {
  type = string
}

variable "private_sg_id" {
  type = string
}

variable "key_name" {
  type = string
}
