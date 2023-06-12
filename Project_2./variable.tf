

variable "ami" {
  description = "AMI of the instance"
  type        = string
  default     = "ami-05842f1afbf311a43"
}

variable "size" {
  description = "type of instance"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "autoscaling group data user"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd.service
              systemctl enable httpd.service
              echo "<html><body><h1>Project week 21</h1></body></html>" > /var/www/html/index.html
              systemctl status
              systemctl restart
              EOF
}


variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}



#These Public subnets are used for resources that need to be accessible from the internet
variable "public_subnet_cidr" {
  description = "Public Subnet cidr block"
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.2.0/24"]
}

#These Private subnets can be used to deploy resources that do not need to be accessible from the internet.
variable "private_subnet_cidr" {
  description = "Private Subnet cidr block"
  type        = list(string)
  default     = ["10.10.3.0/24", "10.10.4.0/24"]
}

data "aws_vpc" "default" {
  default = true
}

