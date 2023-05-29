variable "subnet" {
    description = "subnet id"
    type= string
    default = "subnet-0b3166e38e2e415e1"
}

variable "ami" {
    description = "AMI of the instance"
    type= string
    default = "ami-05842f1afbf311a43"
}

variable "instance" {
    description = "type of instance"
    type = string
    default = "t2.micro"
}

