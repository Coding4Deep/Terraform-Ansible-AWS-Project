output "public_sg_id" {
  value = aws_security_group.terraform-public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.terraform-private_sg.id
}
