variable "aws_region" {
  type = string
  default = "eu-north-1"
}

variable "allowed_ssh_cidr" {
  description = "Your public IP with /32. Find via: curl -s ifconfig.me"
  type = string
}