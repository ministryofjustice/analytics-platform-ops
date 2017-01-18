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

variable "cidr_blocks_rds" {
  type = "list"

  default = [
    "172.20.20.0/24",
    "172.20.24.0/24",
    "172.20.28.0/24"
  ]
}
