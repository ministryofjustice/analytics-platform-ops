output "region" {
  value = "${var.region}"
}

output "terraform_bucket_name" {
  value = "${var.terraform_bucket_name}"
}

output "terraform_base_state_file" {
  value = "${var.terraform_base_state_file}"
}

output "vpc_id" {
  value = "${module.aws_vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "dns_zone_domain" {
  value = "${module.cluster_dns.dns_zone_domain}"
}

output "dns_zone_id" {
  value = "${module.cluster_dns.dns_zone_id}"
}

output "dmz_subnets" {
  value = "${module.aws_vpc.dmz_subnets}"
}

output "private_subnets" {
  value = "${module.aws_vpc.private_subnets}"
}

output "extra_bastion_sg_id" {
  value = "${module.aws_vpc.extra_bastion_sg_id}"
}

output "extra_master_sg_id" {
  value = "${module.aws_vpc.extra_master_sg_id}"
}

output "extra_node_sg_id" {
  value = "${module.aws_vpc.extra_node_sg_id}"
}
