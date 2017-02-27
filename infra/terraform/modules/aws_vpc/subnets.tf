resource "aws_subnet" "dmz" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.dmz_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count = "${length(var.availability_zones)}"

  tags = {
    Name = "dmz-${element(var.availability_zones, count.index)}.${var.name}"
    Cluster = "${var.name}"
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
  count = "${length(var.availability_zones)}"
}


resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.private_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count = "${length(var.availability_zones)}"

  tags = {
    Name = "private-${element(var.availability_zones, count.index)}.${var.name}"
    Cluster = "${var.name}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count = "${length(var.availability_zones)}"
}


resource "aws_subnet" "storage" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${element(var.storage_cidr_blocks, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  count = "${length(var.availability_zones)}"

  tags = {
    Name = "storage-${element(var.availability_zones, count.index)}.${var.name}"
    Cluster = "${var.name}"
  }
}

resource "aws_route_table_association" "storage" {
  subnet_id      = "${element(aws_subnet.storage.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count = "${length(var.availability_zones)}"
}
