resource "aws_route53_zone" "env" {
  name          = "${terraform.workspace}.${var.root_zone_name}"
  force_destroy = true
}

resource "aws_route53_record" "root_ns_record" {
  zone_id = var.root_zone_id
  name    = terraform.workspace
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.env.name_servers
}
