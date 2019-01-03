# Workaround for the data.aws_route53_zone inside the
# Atlantis module not calculating our aws_route53_zone.global
# resource as a dependency at plan time
data "aws_route53_zone" "global" {
  name = "${aws_route53_zone.global.name}"

  depends_on = [
    "aws_route53_zone.global",
    "aws_route53_record.global_ns",
  ]
}

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "1.5.1"

  name = "atlantis"

  atlantis_image = "quay.io/mojanalytics/atlantis:master"
  allow_repo_config = "true"

  cidr            = "${var.atlantis_vpc_cidr_block}"
  azs             = ["${var.atlantis_vpc_availability_zones}"]
  private_subnets = ["${var.atlantis_vpc_private_subnets_cidr_blocks}"]
  public_subnets  = ["${var.atlantis_vpc_public_subnets_cidr_blocks}"]

  route53_zone_name = "${data.aws_route53_zone.global.name}"

  atlantis_github_user       = "mojanalytics"
  atlantis_github_user_token = "${var.atlantis_github_user_token}"

  atlantis_repo_whitelist = [
    "github.com/ministryofjustice/analytics-platform-atlantis-example",
  ]

  github_organization = "ministryofjustice"
  github_token        = "${var.atlantis_github_user_token}"

  github_repo_names = [
    "analytics-platform-atlantis-example",
  ]
}
