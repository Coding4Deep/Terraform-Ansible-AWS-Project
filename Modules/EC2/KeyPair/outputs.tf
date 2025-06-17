output "key_name" {
  value = aws_key_pair.ec2_key.key_name
}

output "private_key_pem_path" {
  value = local_file.private_key_pem.filename
}
