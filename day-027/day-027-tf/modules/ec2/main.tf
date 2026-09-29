data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}


resource "aws_instance" "this" {
  ami = data.aws_ssm_parameter.ubuntu.value
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "${var.name_prefix}-ec2"
  }
}