variable "vpc_id" {}
variable "account_id" {}

variable "k8s_worker_role_arn" {}

variable "db_username" {}
variable "db_password" {}

variable "storage_type" {
  default = "gp2"
}

variable "allocated_storage" {
  default = 5
}

variable "engine" {
  default = "postgres"
}

variable "engine_version" {
  default = "9.6.2"
}

variable "instance_class" {
  default = "db.m1.small"
}

variable "db_subnet_ids" {
  type = "list"
}

variable "ingress_security_group_ids" {
  type = "list"
}

variable "redis_node_type" {
  default = "cache.t3.medium"
}

variable "redis_port" {
  default = 6379
}

variable "redis_password" {}

variable "redis_engine_version" {
  default = "5.0.6"
}

variable "availability_zones" {
  type = "list"

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to the this module's resources"
}
