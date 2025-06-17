resource "aws_instance" "public_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.public_sg_id]

  tags = {
    Name = "Public-EC2-Tomcat"
  }
}

resource "aws_eip" "public_ec2_eip" {
  instance = aws_instance.public_ec2.id
  vpc      = true
}