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
