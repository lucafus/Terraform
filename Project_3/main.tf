#AWS Instances

resource "aws_instance" "web_server" {
  subnet_id              = var.public_subnet_cidr[0]
  ami                    = var.ami
  instance_type          = var.instance
  vpc_security_group_ids = [aws_security_group.project_22_WebServer.id]
  key_name               = aws_key_pair.generated.key_name

  provisioner "local-exec" {
    command     = "chmod 600 ${local_file.private_key_pem.filename}"
    working_dir = path.module
  }

  provisioner "remote-exec" {
    inline = [
      #!/bin/bash
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd.service",
      "sudo systemctl enable httpd.service",
      "sudo echo \"<html><body><h1>Project week 21</h1></body></html>\" > /var/www/html/index.html",
      "sudo systemctl status",
      "sudo systemctl restart",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"                                # Specify the SSH user for the EC2 instance
    private_key = tls_private_key.generated.private_key_pem # Use the private key content directly
    host        = self.public_ip                            # Use the public IP of the EC2 instance
  }
}


resource "aws_instance" "RDS_MySQL" {
  subnet_id              = var.private_subnet_cidr[0]
  ami                    = var.ami
  instance_type          = var.instance
  vpc_security_group_ids = [aws_security_group.project_22_WebServer.id]
  key_name               = aws_key_pair.generated.key_name
  
  
  }
  
  