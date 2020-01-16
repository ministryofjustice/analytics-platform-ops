variable "env" {}
variable "vpc_id" {}
variable "dns_zone_id" {}
variable "dns_zone_domain" {}
variable "node_security_group_id" {}
variable "bastion_security_group_id" {}
variable "ssh_public_key" {}

variable "name_identifier" {
  default     = "softnas"
  description = "Will be interpolated into resource names, e.g. EBS volume 'softnas' -> 'dev-softnas-vol1'"
}

variable "nfs_dns_prefix" {
  default     = "nfs"
  description = "First part of NFS DNS record, e.g. 'nfs' -> 'nfs.dev.mojanalytics.xyz'"
}

variable "subnet_ids" {
  type = "list"
}

variable "num_instances" {
  default = 2
}

variable "softnas_ami_id" {
  default = "ami-6498ac02"
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

variable "is_production" {
  default     = "true"
  description = "determine the value of the is-production Tag of the EBS volumes"
}

variable "tags" {
  type = "map"

  default = {
    business-unit = "Platforms"
    application   = "analytical-platform"
    component     = "SoftNAS"
    owner         = "analytical-platform:analytics-platform-tech@digital.justice.gov.uk"
  }
}
