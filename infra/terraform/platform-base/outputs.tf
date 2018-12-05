output "region" {
  value = "${var.region}"
}

output "terraform_bucket_name" {
  value = "${var.terraform_bucket_name}"
}

output "terraform_global_state_file" {
  value = "${var.terraform_global_state_file}"
}

output "vpc_id" {
  value = "${module.aws_vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "dmz_subnet_ids" {
  value = "${module.aws_vpc.dmz_subnet_ids}"
}

output "private_subnet_ids" {
  value = "${module.aws_vpc.private_subnet_ids}"
}

output "storage_subnet_ids" {
  value = "${module.aws_vpc.storage_subnet_ids}"
}

output "availability_zones" {
  value = "${var.availability_zones}"
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

output "oidc_provider_url" {
  value = "${var.oidc_provider_url}"
}

output "oidc_client_ids" {
  value = "${var.oidc_client_ids}"
}

output "oidc_provider_thumbprints" {
  value = "${var.oidc_provider_thumbprints}"
}
