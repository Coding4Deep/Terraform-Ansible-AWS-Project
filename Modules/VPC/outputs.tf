output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "public_subnet_id" {
  value = module.public_subnet.public_subnet_id
}

output "private_subnet_id" {
  value = module.private_subnet.private_subnet_id
  
}
