variable "cluster_dns_name" {}
variable "cluster_dns_zone" {}

variable "availability_zones" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "public_subnet_cidr_blocks" {
  type = "list"
}

variable "public_subnet_availability_zones" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "private_subnet_cidr_blocks" {
  type = "list"
}

variable "private_subnet_availability_zones" {
  type = "list"
}

variable "instancegroup_image" {}

variable "masters_extra_sg_id" {}
variable "masters_machine_type" {}
variable "masters_root_volume_size" {}

variable "nodes_extra_sg_id" {}
variable "nodes_machine_type" {}
variable "nodes_instancegroup_max_size" {}
variable "nodes_instancegroup_min_size" {}
variable "nodes_root_volume_size" {}

variable "highmem_nodes_machine_type" {}
variable "highmem_nodes_instancegroup_max_size" {}
variable "highmem_nodes_instancegroup_min_size" {}
variable "highmem_nodes_root_volume_size" {}

variable "bastions_extra_sg_id" {}
variable "bastions_machine_type" {}
variable "bastions_instancegroup_max_size" {}
variable "bastions_instancegroup_min_size" {}
variable "bastions_root_volume_size" {}

variable "kops_state_bucket" {}
variable "oidc_client_id" {}
variable "oidc_issuer_url" {}
variable "k8s_version" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
