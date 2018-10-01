resource "aws_route53_zone" "platform_zone" {
  name          = "${var.platform_root_domain}."
  force_destroy = "false"
}
