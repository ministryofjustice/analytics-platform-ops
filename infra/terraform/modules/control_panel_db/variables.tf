variable "env" {}
variable "vpc_id" {}

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
