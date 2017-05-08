resource "aws_route53_record" "elasticsearch" {
   zone_id = "${var.dns_zone_id}"
   name = "elasticsearch"
   type = "CNAME"
   ttl = "30"
   records = ["${aws_elasticsearch_domain.logging.endpoint}"]
}
