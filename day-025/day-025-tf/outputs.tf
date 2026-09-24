output "vpc_id" {
  description = "ID of the Lab VPC"
  value = aws_vpc.lab_vpc.id
}

output "instance_id" {
  description = "ID of the provisioned EC2 instance"
  value = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value = aws_instance.web_server.public_dns
}

output "website_url" {
  description = "Direct HTTP URL to the test page"
  value = "http://${aws_instance.web_server.public_ip}"
}