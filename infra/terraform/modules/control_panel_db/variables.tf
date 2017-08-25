variable "env" {}

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
