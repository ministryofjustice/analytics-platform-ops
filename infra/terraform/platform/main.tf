terraform {
  backend "s3" {
    bucket               = "terraform.analytics.justice.gov.uk"
    workspace_key_prefix = "platform:"
    key                  = "terraform.tfstate"
    region               = "eu-west-1"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.45"
}

module "data_buckets" {
  source = "../modules/data_buckets"

  env = "${terraform.workspace}"
}

module "user_nfs_softnas" {
  source = "../modules/user_nfs_softnas"

  env                       = "${terraform.workspace}"
  num_instances             = "${var.softnas_num_instances}"
  softnas_ami_id            = "${var.softnas_ami_id}"
  instance_type             = "${var.softnas_instance_type}"
  default_volume_size       = "${var.softnas_volume_size}"
  vpc_id                    = "${data.terraform_remote_state.platform_base.vpc_id}"
  node_security_group_id    = "${data.terraform_remote_state.platform_base.extra_node_sg_id}"
  bastion_security_group_id = "${data.terraform_remote_state.platform_base.extra_bastion_sg_id}"
  subnet_ids                = "${data.terraform_remote_state.platform_base.storage_subnet_ids}"
  ssh_public_key            = "${var.softnas_ssh_public_key}"
  dns_zone_id               = "${data.terraform_remote_state.platform_base.dns_zone_id}"
  dns_zone_domain           = "${data.terraform_remote_state.platform_base.dns_zone_domain}"
  is_production             = "${var.is_production}"

  tags = "${merge(map(
    "component", "SoftNAS",
  ), var.tags)}"
}

module "ebs_snapshots" {
  source = "../modules/ebs_snapshots"

  name = "${terraform.workspace}-dlm"
  env  = "${terraform.workspace}"

  target_tags = {
    env = "${terraform.workspace}"
  }

  tags = "${var.tags}"
}

module "softnas_monitoring" {
  source = "../modules/cloudwatch_alerts"

  name               = "${terraform.workspace}-softnas-alerts"
  ec2_instance_ids   = "${module.user_nfs_softnas.ec2_instance_ids}"
  ec2_instance_names = "${module.user_nfs_softnas.ec2_instance_names}"
  cpu_threshold      = 80
  email              = "analytics-platform-tech@digital.justice.gov.uk"

  tags = "${merge(map(
    "component", "SoftNAS",
  ), var.tags)}"
}

module "concourse_parameter_user" {
  source = "../modules/user_get_parameter"

  user_name = "concourse"
  env       = "${terraform.workspace}"
}

module "data_backup" {
  source = "../modules/data_backup"

  env                 = "${terraform.workspace}"
  k8s_worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"
  logs_bucket_arn     = "${data.terraform_remote_state.global.s3_logs_bucket_name}"
}

module "encrypt_scratch_lambda_function" {
  source = "../modules/lambda_functions"

  env        = "${terraform.workspace}"
  bucket_id  = "${module.data_buckets.scratch_bucket_id}"
  bucket_arn = "${module.data_buckets.scratch_bucket_arn}"
}

module "encrypt_crest_lambda_function" {
  source = "../modules/lambda_functions"

  env        = "${terraform.workspace}"
  bucket_id  = "${module.data_buckets.crest_bucket_id}"
  bucket_arn = "${module.data_buckets.crest_bucket_arn}"
}

module "container_registry" {
  source = "../modules/container_registry"

  env = "${terraform.workspace}"
}

module "control_panel_api" {
  source = "../modules/control_panel_api"

  env                        = "${terraform.workspace}"
  db_username                = "${var.control_panel_api_db_username}"
  db_password                = "${var.control_panel_api_db_password}"
  k8s_worker_role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"
  account_id                 = "${data.aws_caller_identity.current.account_id}"
  vpc_id                     = "${data.terraform_remote_state.platform_base.vpc_id}"
  db_subnet_ids              = ["${data.terraform_remote_state.platform_base.storage_subnet_ids}"]
  ingress_security_group_ids = ["${data.terraform_remote_state.platform_base.extra_node_sg_id}"]
}

module "airflow_storage_efs_volume" {
  source = "../modules/efs_volume"

  name                   = "${terraform.workspace}-airflow-storage"
  vpc_id                 = "${data.terraform_remote_state.platform_base.vpc_id}"
  node_security_group_id = "${data.terraform_remote_state.platform_base.extra_node_sg_id}"
  subnet_ids             = "${data.terraform_remote_state.platform_base.storage_subnet_ids}"
  num_subnets            = "${length(data.terraform_remote_state.platform_base.storage_subnet_ids)}"
}

module "airflow_db" {
  source = "../modules/postgres_db"

  instance_name          = "${terraform.workspace}-airflow"
  instance_class         = "db.m3.medium"
  db_name                = "airflow"
  username               = "${var.airflow_db_username}"
  password               = "${var.airflow_db_password}"
  vpc_id                 = "${data.terraform_remote_state.platform_base.vpc_id}"
  node_security_group_id = "${data.terraform_remote_state.platform_base.extra_node_sg_id}"
  subnet_ids             = "${data.terraform_remote_state.platform_base.storage_subnet_ids}"
}

module "airflow_smtp_user" {
  source = "../modules/ses_smtp_user"

  ses_address_identity_arn = "${var.ses_ap_email_identity_arn}"
  iam_user_name            = "${terraform.workspace}_airflow_smtp_user"
}

module "cert_manager" {
  source = "../modules/ec2_cert_manager_role"

  role_name      = "${terraform.workspace}-cert-manager"
  trusted_entity = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"]
  hosted_zone_id = "${data.terraform_remote_state.platform_base.dns_zone_id}"
}

resource "aws_iam_policy" "read-user-roles-inline-policies" {
  name = "${terraform.workspace}-read-user-roles-inline-policies"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CanReadUserRolesInlinePolicies",
            "Effect": "Allow",
            "Action": [
                "iam:GetRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${terraform.workspace}_user_*"
            ]
        }
    ]
}
EOF
}

module "cluster_autoscaler" {
  source = "../modules/ec2_cluster_autoscaler_policy"

  policy_name        = "${terraform.workspace}-cluster-autoscaler"
  instance_role_name = ["nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"]

  auto_scaling_groups = [
    "nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}",
    "highmem-nodes.${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}",
  ]
}

module "archived_buckets_bucket" {
  source = "../modules/archived_buckets_bucket"

  name                = "${terraform.workspace}-archived-buckets-data"
  logging_bucket_name = "${data.terraform_remote_state.global.s3_logs_bucket_name}"
  expiration_days     = 183                                                         # 6 months
  region              = "${var.region}"

  tags = "${var.tags}"
}
