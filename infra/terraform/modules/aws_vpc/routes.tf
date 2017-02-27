resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "dev.mojanalytics.xyz"
    Cluster = "dev.mojanalytics.xyz"
  }
}

resource "aws_route" "dmz" {
  route_table_id         = "${aws_route_table.dmz.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}


resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(var.availability_zones)}"

  tags = {
    Name = "private-${element(var.availability_zones, count.index)}.${var.name}"
    Cluster = "dev.mojanalytics.xyz"
  }
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.private_gw.*.id, count.index)}"
  count = "${length(var.availability_zones)}"
}
