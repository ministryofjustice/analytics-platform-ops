terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "base/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.15"
}

data "aws_caller_identity" "current" {}

module "aws_account_logging" {
  source = "../modules/aws_account_logging"

  es_domain   = "${var.es_domain}"
  es_port     = "${var.es_port}"
  es_scheme   = "${var.es_scheme}"
  es_username = "${var.es_username}"
  es_password = "${var.es_password}"

  cloudtrail_s3_bucket_arn = "${aws_s3_bucket.global_cloudtrail.arn}"
  cloudtrail_s3_bucket_id  = "${aws_s3_bucket.global_cloudtrail.id}"

  account_id = "${data.aws_caller_identity.current.account_id}"
}

module "log_pruning" {
  source = "../modules/log_pruning"

  curator_conf = <<EOF
- name: main
  endpoint: ${var.es_scheme}://${var.es_username}:${var.es_password}@${var.es_domain}:${var.es_port}
  indices:
    - prefix: s3logs-
      days: 30
    - prefix: cloudtrail-
      days: 30
    - prefix: logstash-dev-
      days: 2
    - prefix: logstash-apps-dev-
      days: 2
    - prefix: logstash-alpha-
      days: 30
    - prefix: logstash-apps-alpha-
      days: 30
EOF
}

module "hmpps_nomis_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "nomis"
}

module "hmpps_oasys_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "oasys"
}

// Backup etcd volumes attached to kubernetes masters -->

variable "environment_variables" {
  type = "map"

  default = {
    "TAG_KEY"            = "etcd"
    "TAG_VALUE"          = "1"
    "INSTANCE_TAG_KEY"   = "k8s.io/role/master"
    "INSTANCE_TAG_VALUE" = "1"
  }
}

// Create Snapshot policy document
data "template_file" "lambda_create_snapshot_policy" {
  template = "${file("assets/create_etcd_ebs_snapshot/lambda_create_snapshot_policy.json")}"
}

// Lambda requires that we zip the distribution in order to deploy it
data "archive_file" "kubernetes_etcd_ebs_snapshot_code" {
  source_file = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot"
  output_path = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  type        = "zip"
}

module "kubernetes_etcd_ebs_snapshot" {
  source                = "../modules/lambda_mgmt"
  lambda_function_name  = "create_etcd_ebs_snapshot"
  zipfile               = "assets/create_etcd_ebs_snapshot/create_etcd_ebs_snapshot.zip"
  handler               = "create_etcd_ebs_snapshot"
  source_code_hash      = "${data.archive_file.kubernetes_etcd_ebs_snapshot_code.output_base64sha256}"
  lamda_policy          = "${data.template_file.lambda_create_snapshot_policy.rendered}"
  environment_variables = "${var.environment_variables}"
}

// -->

