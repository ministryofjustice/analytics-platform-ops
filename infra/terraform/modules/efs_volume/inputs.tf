variable "name" {}

variable "vpc_id" {}
variable "node_security_group_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "num_subnets" {}

variable "performance_mode" {
  default = "generalPurpose"
}

variable "throughput_mode" {
  default = "bursting"
}

# applies when throughput_mode = "provisioned"
variable "provisioned_throughput_in_mibps" {
  default = "0"
}
