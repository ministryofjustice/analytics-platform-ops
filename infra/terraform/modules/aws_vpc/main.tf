variable "name" {}
variable "cidr" {}
variable "availability_zones" {
    default = [
        "eu-west-1a",
        "eu-west-1b",
        "eu-west-1c"
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

output "extra_node_sg_id" {
    value = "${aws_security_group.node_extra.id}"
}
