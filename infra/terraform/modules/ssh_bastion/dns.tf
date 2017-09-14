resource "aws_route53_record" "bastion" {
  zone_id   = "${var.dns_zone_id}"
  name      = "bastion"
  type      = "A"

  alias {
    name = "${aws_elb.bastions.dns_name}"
    zone_id = "${aws_elb.bastions.zone_id}"
    evaluate_target_health = false
  }

  count = "${var.use_elb}"
}
