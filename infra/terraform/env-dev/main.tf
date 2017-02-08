provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "${var.terraform_bucket_name}"
        region = "${var.region}"
        key = "${var.terraform_base_state_file}"
    }
}


module "aws_vpc" {
    source = "../modules/aws_vpc"

    name = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
    cidr = "${var.vpc_cidr}"
}

module "cluster_dns" {
    source = "../modules/cluster_dns"

    env = "${var.env}"
    root_zone_name = "${data.terraform_remote_state.base.xyz_dns_zone_name}"
    root_zone_domain = "${data.terraform_remote_state.base.xyz_root_domain}"
    root_zone_id = "${data.terraform_remote_state.base.xyz_dns_zone_id}"
}

module "data_buckets" {
    source = "../modules/data_buckets"

    env = "${var.env}"
}
