output "region" {
    value = "${var.region}"
}

output "xyz_dns_zone_id" {
    value = "${aws_route53_zone.xyz_zone.id}"
}

output "xyz_dns_zone_name" {
    value = "${aws_route53_zone.xyz_zone.name}"
}

output "xyz_root_domain" {
    value = "${var.xyz_root_domain}"
}

output "kops_bucket_name" {
    value = "${var.kops_bucket_name}"
}
