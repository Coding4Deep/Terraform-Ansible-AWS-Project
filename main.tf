terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source              = "./Modules/VPC"
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  public_subnet_az    = var.public_subnet_az
  private_subnet_cidr = var.private_subnet_cidr
  private_subnet_az   = var.private_subnet_az
}

module "security_groups" {
  source = "./Modules/SecurityGroups"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source   = "./Modules/EC2/"
  key_name = var.key_name
  ami_id   = var.ami_id
  instance_type = var.instance_type
  public_sg_id = module.security_groups.public_sg_id
  public_subnet_id = module.vpc.
}
