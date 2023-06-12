
# Public_Subnets

resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
}

# Private_Subnets

resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr[count.index]
  map_public_ip_on_launch = true
}