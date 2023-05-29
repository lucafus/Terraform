provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Project Security Group for IN"

  ingress {
    description = "Allow Inbound HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-sg"
  }
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "jenkins.pem"
}

resource "aws_key_pair" "generated" {
  key_name   = "jenkins"
  public_key = tls_private_key.generated.public_key_openssh
  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "aws_instance" "project_instance" {
  subnet_id              = "subnet-0b3166e38e2e415e1"
  ami                    = "ami-05842f1afbf311a43"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.generated.key_name

  provisioner "local-exec" {
    command     = "chmod 600 ${local_file.private_key_pem.filename}"
    working_dir = path.module
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum upgrade -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl status jenkins"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"                                # Specify the SSH user for the EC2 instance
    private_key = tls_private_key.generated.private_key_pem # Use the private key content directly
    host        = self.public_ip                            # Use the public IP of the EC2 instance
  }
}

resource "aws_s3_bucket" "jenkins" {
  bucket = "my-jenkins-bucket24523"
}

resource "aws_s3_bucket_ownership_controls" "privacy" {
  bucket = aws_s3_bucket.jenkins.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "jenkins" {
  bucket = aws_s3_bucket.jenkins.id
  acl    = "private"
}
