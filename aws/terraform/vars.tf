variable "region" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "main_db_username" {
  type = "string"
}

variable "main_db_password" {
  type = "string"
}

variable "zones" {
  type = "list"

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

variable "node_security_group_id" {
  type = "string"
}

variable "cidr_blocks_storage" {
  type = "list"

  default = [
    "172.20.20.0/24",
    "172.20.24.0/24",
    "172.20.28.0/24"
  ]
}
