terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "dev-env-example/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}

module "aws_vpc" {
  source = "../../modules/aws_vpc"

  name               = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
  cidr               = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
}

module "cluster_dns" {
  source = "../../modules/cluster_dns"

  env              = "${var.env}"
  root_zone_name   = "${data.terraform_remote_state.base.xyz_dns_zone_name}"
  root_zone_domain = "${data.terraform_remote_state.base.xyz_root_domain}"
  root_zone_id     = "${data.terraform_remote_state.base.xyz_dns_zone_id}"
}

module "aws_ec2" {
  source = "../../modules/aws_ec2"

  ssh_key_name   = "${module.cluster_dns.dns_zone_domain}"
  ssh_public_key = "${var.ssh_public_key}"
}

module "ssh_bastion" {
  source = "../../modules/ssh_bastion"

  env        = "${var.env}"
  vpc_id     = "${module.aws_vpc.vpc_id}"
  name       = "bastions.${module.cluster_dns.dns_zone_domain}"
  subnet_ids = ["${module.aws_vpc.dmz_subnet_ids}"]
  key_name   = "${module.aws_ec2.ssh_key_name}"
}

module "k8s_access_control" {
  source = "../../modules/kubernetes_access_control"

  vpc_id                   = "${module.aws_vpc.vpc_id}"
  cluster_name             = "${module.cluster_dns.dns_zone_domain}"
  kops_bucket_arn          = "${data.terraform_remote_state.base.kops_bucket_arn}"
  inbound_ssh_source_sg_id = "${module.ssh_bastion.bastion_sg_id}"
}

module "k8s_cluster" {
  source = "../../modules/kubernetes_cluster"

  availability_zones = ["${var.availability_zones}"]

  vpc_id                   = "${module.aws_vpc.vpc_id}"
  vpc_cidr                 = "${module.aws_vpc.cidr}"
  vpc_public_subnet_ids    = ["${module.aws_vpc.dmz_subnet_ids}"]
  vpc_private_subnet_ids   = ["${module.aws_vpc.private_subnet_ids}"]
  vpc_public_subnet_zones  = "${module.aws_vpc.dmz_subnets}"
  vpc_private_subnet_zones = "${module.aws_vpc.private_subnets}"
  vpc_public_subnet_cidrs  = "${module.aws_vpc.dmz_subnet_cidrs}"
  vpc_private_subnet_cidrs = "${module.aws_vpc.private_subnet_cidrs}"
  vpc_nat_gateway_subnets  = "${module.aws_vpc.nat_gateway_subnets}"

  sg_allow_ssh    = "${module.k8s_access_control.inbound_ssh_sg_id}"
  sg_allow_http_s = "${module.k8s_access_control.inbound_http_sg_id}"

  cluster_name = "${var.env}"
  cluster_fqdn = "${module.cluster_dns.dns_zone_domain}"

  route53_zone_id = "${module.cluster_dns.dns_zone_id}"

  kops_s3_bucket_arn = "${data.terraform_remote_state.base.kops_bucket_arn}"
  kops_s3_bucket_id  = "${data.terraform_remote_state.base.kops_bucket_id}"

  instance_key_name = "${module.aws_ec2.ssh_key_name}"
  ssh_public_key    = "${module.aws_ec2.ssh_public_key}"

  master_iam_instance_profile = "${module.k8s_access_control.masters_instance_profile_id}"
  node_iam_instance_profile   = "${module.k8s_access_control.nodes_instance_profile_id}"

  master_instance_type = "${var.master_instance_type}"
  node_instance_type   = "${var.node_instance_type}"

  node_asg_min     = "${var.num_nodes}"
  node_asg_desired = "${var.num_nodes}"
  node_asg_max     = "${var.num_nodes}"

  kubernetes_version = "${var.kubernetes_version}"
}
