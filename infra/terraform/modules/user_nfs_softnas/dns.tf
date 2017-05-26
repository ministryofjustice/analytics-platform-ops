resource "aws_route53_record" "softnas" {
   zone_id = "${var.dns_zone_id}"
   name = "softnas-${count.index}.${var.dns_zone_domain}"
   type = "A"
   ttl = "30"
   records = ["${element(aws_instance.softnas.*.private_ip, count.index)}"]

   count = "${var.num_instances}"
}

resource "aws_route53_record" "nfs_mountpoint" {
   zone_id = "${var.dns_zone_id}"
   name = "nfs.${var.dns_zone_domain}"
   type = "A"
   ttl = "30"
   records = ["${var.nfs_mountpoint_ip}"]
}
