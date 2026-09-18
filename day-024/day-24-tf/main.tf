resource "aws_vpc" "main" {
  cidr_block = "10.24.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "day24-lab-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.24.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "day24-lab-public-sub"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.24.2.0/24"
  availability_zone = "eu-north-1b"

  tags = {
    Name = "day24-lab-private-sub"
  }
}