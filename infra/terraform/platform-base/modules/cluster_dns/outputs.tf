output "dns_zone_id" {
  value = aws_route53_zone.env.id
}

output "dns_zone_domain" {
  value = "${terraform.workspace}.${var.root_zone_domain}"
}
