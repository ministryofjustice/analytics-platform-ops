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

resource "aws_subnet" "storage" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.storage_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count = "${length(var.availability_zones)}"

  tags = {
    Name = "storage-${element(var.availability_zones, count.index)}.${var.name}"
  }
}
