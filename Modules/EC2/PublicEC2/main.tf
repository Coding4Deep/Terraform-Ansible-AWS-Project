resource "aws_instance" "public_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.public_sg_id]

  tags = {
    Name = "Tomcat"
  }
}


resource "aws_eip" "public_ec2_eip" {
  instance = aws_instance.public_ec2.id
  vpc      = true
}



resource "null_resource" "copy_pem_to_public" {
  depends_on = [aws_instance.public_ec2,aws_eip.public_ec2_eip]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.public_ec2.public_ip
    private_key = var.key_content
  }

  provisioner "file" {
    content     = var.key_content
    destination = "/home/ubuntu/Terraform-Project.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/Terraform-Project.pem"
    ]
  }
}
