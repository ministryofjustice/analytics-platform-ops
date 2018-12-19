resource "aws_route53_zone" "platform_zone" {
  name          = "${var.platform_root_domain}."
  force_destroy = "false"
}

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
