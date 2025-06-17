resource "aws_security_group" "terraform-public_sg" {
  name        = "terraform-public-sg"
  description = "Allow inbound HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH from anywhere or restrict as needed
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Tomcat HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Public-SG"
  }
}

resource "aws_security_group" "terraform-private_sg" {
  name        = "terraform-private-sg"
  description = "Allow traffic from Tomcat and to internet via NAT"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform-public_sg.id] # Allow from public SG
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.terraform-public_sg.id] # Allow all traffic from Tomcat EC2
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform-public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # For internet via NAT Gateway
  }

  tags = {
    Name = "Terraform-Private-SG"
  }
}
