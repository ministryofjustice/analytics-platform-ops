variable "instance_name" {}
variable "db_name" {}
variable "username" {}
variable "password" {}

variable "vpc_id" {}
variable "node_security_group_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "allocated_storage" {
  default = 10
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "storage_type" {
  default = "gp2"
}
