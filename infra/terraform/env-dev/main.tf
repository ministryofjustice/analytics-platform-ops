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
    availability_zones = "${var.availability_zones}"
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

module "user_nfs" {
    source = "../modules/user_nfs"

    cluster_name = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
    vpc_id = "${module.aws_vpc.vpc_id}"
    node_security_group_id = "${module.aws_vpc.extra_node_sg_id}"
    subnet_ids = "${module.aws_vpc.storage_subnet_ids}"
    availability_zones = "${var.availability_zones}"
}
