output "private_subnet_id" {
  value       = aws_subnet.private-subnet.id
  description = "The ID of the private subnet"

}
