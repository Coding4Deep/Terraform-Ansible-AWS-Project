resource "aws_instance" "private_ec2" {
  for_each = var.private_instances

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  key_name               = var.key_name

  tags = {
    Name = each.key
  }
}
