terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"
  }
}

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
    source = "../../modules/aws_vpc"

    name = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
    cidr = "${var.vpc_cidr}"
    availability_zones = "${var.availability_zones}"
}

module "cluster_dns" {
    source = "../../modules/cluster_dns"

    env = "${var.env}"
    root_zone_name = "${data.terraform_remote_state.base.xyz_dns_zone_name}"
    root_zone_domain = "${data.terraform_remote_state.base.xyz_root_domain}"
    root_zone_id = "${data.terraform_remote_state.base.xyz_dns_zone_id}"
}

module "data_buckets" {
    source = "../../modules/data_buckets"

    env = "${var.env}"
}

module "user_nfs" {
    source = "../../modules/user_nfs"

    env = "${var.env}"
    cluster_name = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
    vpc_id = "${module.aws_vpc.vpc_id}"
    node_security_group_id = "${module.aws_vpc.extra_node_sg_id}"
    subnet_ids = "${module.aws_vpc.storage_subnet_ids}"
    availability_zones = "${var.availability_zones}"
    performance_mode = "maxIO"
}

module "logging_elasticsearch" {
    source = "../../modules/logging_elasticsearch"

    name = "logging-es.${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
    domain_name = "logging-${var.env}"
    vpc_cidr = "${var.vpc_cidr}"
    ingress_ips = "${module.aws_vpc.nat_gateway_public_ips}"
    dns_zone_id = "${module.cluster_dns.dns_zone_id}"
}

module "encrypt_scratch_lambda_function" {
    source = "../../modules/lambda_functions"
    env = "${var.env}"
    bucket_id = "${module.data_buckets.scratch_bucket_id}"
    bucket_arn = "${module.data_buckets.scratch_bucket_arn}"
}

module "encrypt_crest_lambda_function" {
    source = "../../modules/lambda_functions"
    env = "${var.env}"
    bucket_id = "${module.data_buckets.crest_bucket_id}"
    bucket_arn = "${module.data_buckets.crest_bucket_arn}"
}

module "container_registry" {
    source = "../../modules/container_registry"
    env = "${var.env}"
}

module "data_access" {
    source = "../../modules/data_access"

    region = "${var.region}"
    env = "${var.env}"
    sns_arn_base = "${var.sns_arn_base}"
    gh_hook_secret = "${var.gh_hook_secret}"
}
