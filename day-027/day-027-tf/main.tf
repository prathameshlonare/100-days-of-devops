module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.27.0.0/16"
  subnet_cidr = "10.27.1.0/24"
  az = "eu-north-1a"
  name_prefix = "day27-lab"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  name_prefix = "day27-lab"
}

module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.subnet_id
  sg_id = module.sg.sg_id
  instance_type = "t3.micro"
  name_prefix = "day27-lab"
}

