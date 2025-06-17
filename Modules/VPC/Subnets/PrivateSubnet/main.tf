resource "aws_subnet" "private-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "Terraform_Private_Subnet"
    Type = "Private"
  }
}
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "private_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "Terraform_Private_NAT_Gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_nat.id
  }

  tags = {
    Name = "Terraform_Private_Route_Table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
