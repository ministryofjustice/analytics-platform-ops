terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "alpha/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = ">= v1.25.0"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket = "${var.terraform_bucket_name}"
    region = "${var.region}"
    key    = "${var.terraform_base_state_file}"
  }
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

module "data_buckets" {
  source = "../../modules/data_buckets"

  env = "${var.env}"
}

module "user_nfs_softnas" {
  source = "../../modules/user_nfs_softnas"

  num_instances             = 2
  default_volume_size       = 250
  env                       = "${var.env}"
  vpc_id                    = "${module.aws_vpc.vpc_id}"
  node_security_group_id    = "${module.aws_vpc.extra_node_sg_id}"
  bastion_security_group_id = "${module.aws_vpc.extra_bastion_sg_id}"
  subnet_ids                = "${module.aws_vpc.storage_subnet_ids}"
  ssh_public_key            = "${var.softnas_ssh_public_key}"
  dns_zone_id               = "${module.cluster_dns.dns_zone_id}"
  dns_zone_domain           = "${module.cluster_dns.dns_zone_domain}"
}

module "data_backup" {
  source = "../../modules/data_backup"

  env                 = "${var.env}"
  k8s_worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
  logs_bucket_arn     = "${data.terraform_remote_state.base.s3_logs_bucket_name}"
}

module "encrypt_scratch_lambda_function" {
  source     = "../../modules/lambda_functions"
  env        = "${var.env}"
  bucket_id  = "${module.data_buckets.scratch_bucket_id}"
  bucket_arn = "${module.data_buckets.scratch_bucket_arn}"
}

module "encrypt_crest_lambda_function" {
  source     = "../../modules/lambda_functions"
  env        = "${var.env}"
  bucket_id  = "${module.data_buckets.crest_bucket_id}"
  bucket_arn = "${module.data_buckets.crest_bucket_arn}"
}

module "container_registry" {
  source = "../../modules/container_registry"
  env    = "${var.env}"
}

module "federated_identity" {
  source                    = "../../modules/federated_identity"
  env                       = "${var.env}"
  oidc_provider_url         = "${var.oidc_provider_url}"
  oidc_client_ids           = ["${var.oidc_client_ids}"]
  oidc_provider_thumbprints = ["${var.oidc_provider_thumbprints}"]
}

module "control_panel_api" {
  source                     = "../../modules/control_panel_api"
  env                        = "${var.env}"
  db_username                = "${var.control_panel_api_db_username}"
  db_password                = "${var.control_panel_api_db_password}"
  k8s_worker_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
  account_id                 = "${data.aws_caller_identity.current.account_id}"
  vpc_id                     = "${module.aws_vpc.vpc_id}"
  db_subnet_ids              = ["${module.aws_vpc.storage_subnet_ids}"]
  ingress_security_group_ids = ["${module.aws_vpc.extra_node_sg_id}"]
}

module "airflow_storage_efs_volume" {
  source = "../../modules/efs_volume"

  name                   = "${var.env}-airflow-storage"
  vpc_id                 = "${module.aws_vpc.vpc_id}"
  node_security_group_id = "${module.aws_vpc.extra_node_sg_id}"
  subnet_ids             = "${module.aws_vpc.storage_subnet_ids}"
  num_subnets            = "${length(module.aws_vpc.storage_cidr_blocks)}"
}

module "airflow_db" {
  source = "../../modules/postgres_db"

  instance_name = "${var.env}-airflow"
  db_name       = "airflow"
  username      = "${var.airflow_db_username}"
  password      = "${var.airflow_db_password}"

  vpc_id                 = "${module.aws_vpc.vpc_id}"
  node_security_group_id = "${module.aws_vpc.extra_node_sg_id}"
  subnet_ids             = "${module.aws_vpc.storage_subnet_ids}"
}
