terraform {
  backend "s3" {
    bucket         = "terraform.analytics.justice.gov.uk"
    key            = "base/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-global"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.51.0"
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

  s3_logs_bucket_name = "${var.s3_logs_bucket_name}"

  vpcflowlogs_s3_bucket_name = "${var.vpcflowlogs_s3_bucket_name}"

  vpc_id = "${var.vpc_id}"
}

module "mojanalytics_concourse_iam_list_roles_user" {
  source      = "../modules/iam_list_roles"
  org_name    = "mojanalytics"
  system_name = "concourse"
}

module "ses_domain" {
  source = "../modules/ses_domain"
  domain = "${var.platform_root_domain}"

  aws_route53_zone_id = "${aws_route53_zone.platform_zone.zone_id}"
}
