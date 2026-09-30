variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.27.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.27.1.0/24"
}

variable "az" {
  description = "Availability zone"
  type        = string
  default     = "eu-north-1a"
}

variable "name_prefix" {
  description = "Prefix for Name tags"
  type        = string
  default     = "day27-lab"
}