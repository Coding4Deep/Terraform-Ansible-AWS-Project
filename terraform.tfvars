vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidr  = "10.0.0.0/24"
public_subnet_az    = "us-east-1a"
private_subnet_cidr = "10.0.1.0/24"
private_subnet_az   = "us-east-1b"
key_name            = "Terraform-Project"
ami_id              = "ami-020cba7c55df1f615"
instance_type       = "t2.micro"
private_instances = {
  "Memcached" = {
    ami           = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
  },
  "RabbitMQ" = {
    ami           = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
  },
  "MongoDB" = {
    ami           = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
  }
}

