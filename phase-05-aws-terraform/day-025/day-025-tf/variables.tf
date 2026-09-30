variable "aws_region" {
  description = "AWS region for all provisioned resources"
  type = string
  default = "eu-north-1"
}

variable "vpc_cidr" {
  description = "CIRD block for the lab VPC"
  type = string
  default = "10.25.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIRD block for the public subnet"
  type = string
  default = "10.25.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing EC2 key paird in eu-north-1"
  type = string
}