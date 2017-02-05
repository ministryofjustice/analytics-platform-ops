resource "aws_vpc" "main" {
    cidr_block = "${var.cidr}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    tags {
        Name = "${var.name}"
        Cluster = "${var.name}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "${var.name}"
        Cluster = "${var.name}"
    }
}
