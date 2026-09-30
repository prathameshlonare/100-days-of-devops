output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.lab_vpc.id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value = aws_subnet.public_sub.id
}