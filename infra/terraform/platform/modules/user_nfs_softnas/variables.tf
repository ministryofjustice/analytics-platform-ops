variable "vpc_id" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "dns_zone_domain" {
  type = string
}

variable "node_security_group_id" {
  type = string
}

variable "bastion_security_group_id" {
  type = string
}

variable "ssh_public_key" {
}

variable "name_identifier" {
  type        = string
  default     = "softnas"
  description = "Will be interpolated into resource names, e.g. EBS volume 'softnas' -> 'dev-softnas-vol1'"
}

variable "nfs_dns_prefix" {
  type        = string
  default     = "nfs"
  description = "First part of NFS DNS record, e.g. 'nfs' -> 'nfs.dev.mojanalytics.xyz'"
}

variable "subnet_ids" {
  type = list(string)
}

variable "num_instances" {
  type    = number
  default = 2
}

variable "softnas_ami_id" {
  type    = string
  default = "ami-6498ac02"
}

variable "instance_type" {
  type    = string
  default = "m4.large"
}

variable "nfs_mountpoint_ip" {
  type    = string
  default = "172.16.0.1"
}

variable "softnas_role_name" {
  type    = string
  default = "SoftNAS_HA_IAM"
}

variable "default_volume_size" {
  type    = number
  default = 10
}

variable "is_production" {
  type        = string
  description = "determine the value of the is-production Tag of the EBS volumes"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to resources"
}

variable "monitoring" {
  type        = bool
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

