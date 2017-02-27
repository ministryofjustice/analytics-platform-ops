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

resource "aws_eip" "private_gw" {
  vpc = true
  count = "${length(var.availability_zones)}"
}

resource "aws_nat_gateway" "private_gw" {
  allocation_id = "${element(aws_eip.private_gw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.dmz.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw"]
  count         = "${length(var.availability_zones)}"
}
