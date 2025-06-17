resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_az

  tags = {
    Name = "Terraform_Public_Subnet"
  }
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Terraform_Public_IGW"
  }

}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
  tags = {
    Name = "Terraform_Public_Route_Table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}

