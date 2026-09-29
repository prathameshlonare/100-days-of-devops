variable "vpc_id" {
  description = "VPC to attach the SG to"
  type = string
}

variable "allowed_ssh_cidr" {
  description = "Your IP in CIDR from, e.g. 1.2.3.4/32"
  type = string
}

variable "name_prefix" {
  type = string
  default = "day27-lab"
}