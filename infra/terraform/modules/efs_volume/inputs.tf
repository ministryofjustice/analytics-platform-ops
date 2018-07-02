variable "name" {}

variable "vpc_id" {}
variable "node_security_group_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "performance_mode" {
  default = "generalPurpose"
}
