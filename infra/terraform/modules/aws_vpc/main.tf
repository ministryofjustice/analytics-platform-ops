variable "name" {}
variable "cidr" {}
variable "availability_zones" {
    type = "list"
}
variable "storage_cidr_blocks" {
  type = "list"

  default = [
    "192.168.20.0/24",
    "192.168.24.0/24",
    "192.168.28.0/24"
  ]
}


output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "cidr" {
    value = "${aws_vpc.main.cidr_block}"
}

output "availability_zones" {
    value = "${join(",", var.availability_zones)}"
}

output "storage_subnet_ids" {
    value = ["${aws_subnet.storage.*.id}"]
}

output "extra_node_sg_id" {
    value = "${aws_security_group.node_extra.id}"
}

output "extra_master_sg_id" {
    value = "${aws_security_group.master_extra.id}"
}
