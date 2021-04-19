data "aws_caller_identity" "current" {
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_security_group" "node" {
  filter {
    name   = "tag:Name"
    values = ["node-extra.${terraform.workspace}.mojanalytics.xyz"]
  }
}

data "aws_security_group" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["bastion-extra.${terraform.workspace}.mojanalytics.xyz"]
  }
}

data "aws_security_group" "bastion-main" {
  filter {
    name   = "tag:Name"
    values = ["bastion.${terraform.workspace}.mojanalytics.xyz"]
  }
}

data "aws_subnet_ids" "storage" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name = "tag:Name"
    values = [
      "storage-eu-west-1a.${terraform.workspace}.mojanalytics.xyz",
      "storage-eu-west-1b.${terraform.workspace}.mojanalytics.xyz",
      "storage-eu-west-1c.${terraform.workspace}.mojanalytics.xyz",
    ]
  }
}

data "aws_route53_zone" "main" {
  name = "${terraform.workspace}.mojanalytics.xyz"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_lb" "bastion" {
  name = "${terraform.workspace}-bastion-lb"
}

data "aws_lb_target_group" "bastion" {
  name = "${terraform.workspace}-bastion-lb-target"
}
