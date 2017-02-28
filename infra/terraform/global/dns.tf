resource "aws_route53_zone" "xyz_zone" {
   name = "${var.xyz_root_domain}."
   force_destroy = "false"
}
