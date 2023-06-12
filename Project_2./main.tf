#--------------------------------------------------------

# VPC

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
 
}


# Subnets

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
}


# ---------------------------------------------

# Security Group

resource "aws_security_group" "Autoscaling_sg" {
  name        = "Autoscaling_sg"
  description = "Autoscaling Security Group"
  vpc_id      = aws_vpc.vpc.id

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
    Name = "Autoscaling-sg"
  }
}


# ---------------------------------------------

# Key Pair


resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.generated.private_key_pem
  filename = "project_21.pem"
}

resource "aws_key_pair" "generated" {
  key_name   = "Autoscaling"
  public_key = tls_private_key.generated.public_key_openssh
  lifecycle {
    ignore_changes = [key_name]
  }
}


# ---------------------------------------------

# Launch Template

resource "aws_launch_template" "Project_template" {
  name_prefix            = "Project_template"
  image_id               = var.ami
  instance_type          = var.size
  user_data              = base64encode(var.user_data)
  vpc_security_group_ids = [aws_security_group.Autoscaling_sg.id]
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }
}


# Autoscaling Group

resource "aws_autoscaling_group" "project_ags" {
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  vpc_zone_identifier = aws_subnet.public_subnet.*.id
  launch_template {
    id      = aws_launch_template.Project_template.id
    version = "$Latest"
  }
}

# ---------------------------------------------

#Create Internet Gatewa

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
 }
 

#Create route tables for public and private subnets

resource "aws_route_table" "project_21_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

#Create route table associations

resource "aws_route_table_association" "project_21_rts" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.project_21_rt.id
}

