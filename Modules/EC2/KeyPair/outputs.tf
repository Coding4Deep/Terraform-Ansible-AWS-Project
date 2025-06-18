output "key_name" {
  value = aws_key_pair.ec2_key.key_name
}

output "private_key_pem_path" {
  value = local_file.private_key_pem.filename
}

output "private_key_content" {
  value     = tls_private_key.ec2_key.private_key_pem
  description = "The private key content in PEM format"
  sensitive = true
}
