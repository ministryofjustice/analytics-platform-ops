output "env" {
    value = "${var.env}"
}

output "dns_zone_id" {
    value = "${aws_route53_zone.env.id}"
}

output "dns_zone_domain" {
    value = "${var.env}.${data.terraform_remote_state.base.xyz_root_domain}"
}
