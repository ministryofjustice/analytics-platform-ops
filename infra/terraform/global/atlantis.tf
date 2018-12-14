resource "aws_route53_zone" "global" {
  name = "global.${var.platform_root_domain}."
}

resource "aws_route53_record" "global_ns" {
  zone_id = "${aws_route53_zone.platform_zone.zone_id}"
  name    = "${aws_route53_zone.global.name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.global.name_servers.0}",
    "${aws_route53_zone.global.name_servers.1}",
    "${aws_route53_zone.global.name_servers.2}",
    "${aws_route53_zone.global.name_servers.3}",
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "global"
  cidr = "10.0.0.0/16"

  azs             = ["${var.vpc_availability_zones}"]
  private_subnets = ["${var.vpc_private_subnets_cidr_blocks}"]
  public_subnets  = ["${var.vpc_public_subnets_cidr_blocks}"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "global"
  }
}

module "atlantis" {
  source = "terraform-aws-modules/atlantis/aws"

  name = "atlantis"

  # VPC
  cidr            = "${module.vpc.vpc_cidr_block}"
  azs             = ["${var.vpc_availability_zones}"]
  private_subnets = ["${module.vpc.private_subnets_cidr_blocks}"]
  public_subnets  = ["${module.vpc.public_subnets_cidr_blocks}"]

  # DNS (without trailing dot)
  route53_zone_name = "${aws_route53_zone.global.name}"

  # ACM (SSL certificate) - Specify ARN of an existing certificate or new one will be created and validated using Route53 DNS
//   certificate_arn = "arn:aws:acm:eu-west-1:135367859851:certificate/70e008e1-c0e1-4c7e-9670-7bb5bd4f5a84"

  # Atlantis
  atlantis_github_user       = "mojanalytics"
  atlantis_github_user_token = "${var.atlantis_github_user_token}"
  atlantis_repo_whitelist    = ["github.com/ministryofjustice/analytics-platform-ops"]
}
