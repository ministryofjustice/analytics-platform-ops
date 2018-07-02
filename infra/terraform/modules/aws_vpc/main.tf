variable "name" {}
variable "cidr" {}

variable "availability_zones" {
  type = "list"
}

variable "dmz_cidr_blocks" {
  type = "list"

  default = [
    "192.168.0.0/24",
    "192.168.4.0/24",
    "192.168.8.0/24",
  ]
}

variable "private_cidr_blocks" {
  type = "list"

  default = [
    "192.168.10.0/24",
    "192.168.14.0/24",
    "192.168.18.0/24",
  ]
}

variable "storage_cidr_blocks" {
  type = "list"

  default = [
    "192.168.20.0/24",
    "192.168.24.0/24",
    "192.168.28.0/24",
  ]
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "cidr" {
  value = "${aws_vpc.main.cidr_block}"
}

output "availability_zones" {
  value = ["${var.availability_zones}"]
}

output "dmz_subnet_ids" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private.*.id}"]
}

output "storage_subnet_ids" {
  value = ["${aws_subnet.storage.*.id}"]
}

output "storage_cidr_blocks" {
  value = "${var.storage_cidr_blocks}"
}

output "dmz_subnets" {
  value = "${zipmap(aws_subnet.dmz.*.id, aws_subnet.dmz.*.availability_zone)}"
}

output "private_subnets" {
  value = "${zipmap(aws_subnet.private.*.id, aws_subnet.private.*.availability_zone)}"
}

output "dmz_subnet_cidrs" {
  value = "${zipmap(aws_subnet.dmz.*.id, aws_subnet.dmz.*.cidr_block)}"
}

output "private_subnet_cidrs" {
  value = "${zipmap(aws_subnet.private.*.id, aws_subnet.private.*.cidr_block)}"
}

output "extra_node_sg_id" {
  value = "${aws_security_group.node_extra.id}"
}

output "extra_master_sg_id" {
  value = "${aws_security_group.master_extra.id}"
}

output "extra_bastion_sg_id" {
  value = "${aws_security_group.bastion_extra.id}"
}

output "nat_gateway_public_ips" {
  value = ["${aws_nat_gateway.private_gw.*.public_ip}"]
}

output "nat_gateway_subnets" {
  value = "${zipmap(aws_nat_gateway.private_gw.*.subnet_id, aws_nat_gateway.private_gw.*.id)}"
}

# output "sg_inbound_ssh_id" {
#   value = "${aws_security_group.inbound_ssh.id}"
# }


# output "sg_inbound_http_id" {
#   value = "${aws_security_group.inbound_http.id}"
# }
