terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "base/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_caller_identity" "current" {}

module "aws_account_logging" {
    source = "../modules/aws_account_logging"

    es_domain = "${var.es_domain}"
    es_port = "${var.es_port}"
    es_scheme = "${var.es_scheme}"
    es_username = "${var.es_username}"
    es_password = "${var.es_password}"
}
