resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.28.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "day28-lab-vpc"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "web_sg" {
  name = "day28-lab-sg-${terraform.workspace}"
  description = "Managed web security group"
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    description = "Alow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "day28-lab-sg-${terraform.workspace}"
    Environment = terraform.workspace
  }
}