variable "env" {}
variable "vpc_id" {}
variable "dns_zone_id" {}
variable "dns_zone_domain" {}
variable "node_security_group_id" {}
variable "bastion_security_group_id" {}
variable "ssh_public_key" {}

variable "subnet_ids" {
    type = "list"
}

variable "num_instances" {
    default = 2
}

variable "instance_type" {
    default = "m4.large"
}

variable "nfs_mountpoint_ip" {
    default = "172.16.0.1"
}

variable "softnas_role_name" {
    default = "SoftNAS_HA_IAM"
}

variable "default_volume_size" {
    default = 10
}
