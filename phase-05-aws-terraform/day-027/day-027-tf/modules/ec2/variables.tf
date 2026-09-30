variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "name_prefix" {
  type = string
  default = "day27-lab"
}