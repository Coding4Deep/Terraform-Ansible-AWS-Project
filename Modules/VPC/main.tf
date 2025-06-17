resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Terraform-Project"
  }
}

module "public_subnet" {
  source             = "./Subnets/PublicSubnet"
  public_subnet_cidr = var.public_subnet_cidr
  public_subnet_az   = var.public_subnet_az
  vpc_id             = aws_vpc.vpc.id
}

module "private_subnet" {
  source              = "./Subnets/PrivateSubnet"
  private_subnet_cidr = var.private_subnet_cidr
  vpc_id              = aws_vpc.vpc.id
  availability_zone   = var.private_subnet_az
  public_subnet_id    = module.public_subnet.public_subnet_id
}
