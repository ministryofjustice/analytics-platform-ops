variable "vpc_id" {}

variable "kops_bucket_arn" {}

variable "inbound_ssh_source_sg_id" {}

variable "inbound_http_cidr_blocks" {
  type = "list"

  default = [
    "0.0.0.0/0"
  ]
}
