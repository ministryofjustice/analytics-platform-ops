terraform {
  backend "s3" {
    bucket               = "terraform.analytics.justice.gov.uk"
    workspace_key_prefix = "platform-base:"
    key                  = "terraform.tfstate"
    region               = "eu-west-1"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.50"
}

module "aws_vpc" {
  source = "../modules/aws_vpc"

  name               = "${terraform.workspace}.${data.terraform_remote_state.global.platform_root_domain}"
  cidr               = "${var.vpc_cidr}"
  availability_zones = "${var.availability_zones}"
}

module "cluster_dns" {
  source = "../modules/cluster_dns"

  env              = "${terraform.workspace}"
  root_zone_name   = "${data.terraform_remote_state.global.platform_dns_zone_name}"
  root_zone_domain = "${data.terraform_remote_state.global.platform_root_domain}"
  root_zone_id     = "${data.terraform_remote_state.global.platform_dns_zone_id}"
}

module "federated_identity" {
  source = "../modules/federated_identity"

  env                       = "${terraform.workspace}"
  oidc_provider_url         = "${var.oidc_provider_url}"
  oidc_client_id            = "${var.oidc_client_id}"
  oidc_provider_thumbprints = ["${var.oidc_provider_thumbprints}"]
  saml_domain               = "${var.idp_saml_domain}"
  saml_signon_url           = "${var.idp_saml_signon_url}"
  saml_logout_url           = "${var.idp_saml_logout_url}"
  saml_x509_cert            = "${var.idp_saml_x509_cert}"
}

module "kops_spec" {
  source = "../modules/kops_spec"

  cluster_dns_name   = "${module.cluster_dns.dns_zone_domain}"
  cluster_dns_zone   = "${module.cluster_dns.dns_zone_id}"
  availability_zones = ["${module.aws_vpc.availability_zones}"]

  public_subnet_ids                = ["${module.aws_vpc.dmz_subnet_ids}"]
  public_subnet_cidr_blocks        = ["${module.aws_vpc.dmz_subnet_cidr_blocks}"]
  public_subnet_availability_zones = ["${module.aws_vpc.dmz_subnet_availability_zones}"]

  private_subnet_ids                = ["${module.aws_vpc.private_subnet_ids}"]
  private_subnet_cidr_blocks        = ["${module.aws_vpc.private_subnet_cidr_blocks}"]
  private_subnet_availability_zones = ["${module.aws_vpc.private_subnet_availability_zones}"]
}
