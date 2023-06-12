
# VPC

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

data "aws_vpc" "default" {
  default = true
}


# Subnets

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

#AMI

variable "ami" {
  description = "AMI of the instance"
  type        = string
  default     = "ami-05842f1afbf311a43"
}

#Instances

variable "instance" {
  description = "type of instance"
  type        = string
  default     = "t2.micro"
}