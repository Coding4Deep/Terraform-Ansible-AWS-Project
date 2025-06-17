
module "public_ec2" {
  source           = "./PublicEC2"
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  public_subnet_id = var.public_subnet_id
  public_sg_id     = var.public_sg_id
  key_name         = var.key_name
}
