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
