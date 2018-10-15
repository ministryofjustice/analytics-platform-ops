provider "aws" {
  region  = "eu-west-1"
  version = "~> 1.25"
}

module "aws_vpc" {
  source = "../.."

  name               = "test-vpc"
  cidr               = "192.168.0.0/16"
  availability_zones = ["eu-west-1a"]
}

output "vpc_id" {
  value = "${module.aws_vpc.vpc_id}"
}
