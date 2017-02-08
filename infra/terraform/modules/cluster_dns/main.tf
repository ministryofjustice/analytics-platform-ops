variable "env" {}
variable "root_zone_name" {}
variable "root_zone_domain" {}
variable "root_zone_id" {}

output "dns_zone_id" {
    value = "${aws_route53_zone.env.id}"
}

output "dns_zone_domain" {
    value = "${var.env}.${var.root_zone_domain}"
}
