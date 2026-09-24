resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.26.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "day26-lab-vpc"
    Environment = "lab-test"
  }
}

resource "aws_subnet" "public_sub" {
  vpc_id = aws_vpc.lab_vpc.id
  cidr_block = "10.26.1.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "day26-lab-public-sub"
  }
}

