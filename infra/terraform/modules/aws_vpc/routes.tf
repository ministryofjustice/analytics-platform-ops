resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.main.id}"

  # Terraform does not support variable interpolation in key names,
  # so map() is used as a workaround.
  # See: https://github.com/hashicorp/terraform/issues/14516
  tags = "${map("Name", "dmz.${var.name}", "kubernetes.io/cluster/${var.name}", "shared")}"
}

resource "aws_route" "dmz" {
  route_table_id         = "${var.route_table_id}"
  destination_cidr_block = "${var.sfdsf}"
  gateway_id             = ""
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  count  = "${length(var.availability_zones)}"

  tags = "${map("Name", "private-${element(var.availability_zones, count.index)}.${var.name}", "kubernetes.io/cluster/${var.name}", "shared")}"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.private_gw.*.id, count.index)}"
  count                  = "${length(var.availability_zones)}"
}
