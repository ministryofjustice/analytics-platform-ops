resource "aws_route53_record" "softnas" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.name_identifier}-${count.index}.${var.dns_zone_domain}"
  type    = "A"
  ttl     = "30"
  records = ["${element(aws_instance.softnas.*.private_ip, count.index)}"]

  count = "${var.num_instances}"
}

resource "aws_route53_record" "nfs_mountpoint" {
  zone_id = "${var.dns_zone_id}"
  name    = "nfs.${var.dns_zone_domain}"
  type    = "A"
  ttl     = "30"

  # Resolve the to the virtual IP if there are two load-balanced SoftNAS
  # instances; otherwise use the single instance's private IP
  records = ["${var.num_instances == 2 ? var.nfs_mountpoint_ip : aws_instance.softnas.0.private_ip}"]
}
