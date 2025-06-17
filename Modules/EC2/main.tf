module "ec2_keypair" {
  source   = "./KeyPair"
  key_name = "devops-key"

}

module "public_ec2" {
  source            = "./PublicEC2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  public_subnet_id  = module.vpc.public_subnet_id
  public_sg_id      = module.security_groups.public_sg_id
  key_name          = module.ec2_keypair.key_name   
  
}
