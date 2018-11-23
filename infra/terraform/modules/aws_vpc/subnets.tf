# Terraform does not support variable interpolation in key names,
# so map() is used as a workaround, with common tags for all
# subnets defined here, and subnet-specific tags merged in
# as part of the subnet definition.
#
# See: https://github.com/hashicorp/terraform/issues/14516
locals {
  common_tags = "${map(
    "KubernetesCluster", "${var.name}",
    "kubernetes.io/cluster/${var.name}", "shared"
  )}"
}

resource "aws_subnet" "dmz" {
  vpc_id = "${aws_vpc.main.id}"

  # with VPC CIDR of 192.168.0.0/16 and three AZs, returns:
  # 192.168.0.0/24, 192.168.4.0/24, 192.168.8.0/24
  cidr_block = "${cidrsubnet(var.cidr, 8, count.index * 4)}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.availability_zones)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "dmz-${element(var.availability_zones, count.index)}.${var.name}",
      "kubernetes.io/role/elb", "1",
      "SubnetType", "Utility"
    )
  )}"
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
  count          = "${length(var.availability_zones)}"
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"

  # with VPC CIDR of 192.168.0.0/16 and three AZs, returns:
  # 192.168.10.0/24, 192.168.14.0/24, 192.168.18.0/24
  cidr_block = "${cidrsubnet(var.cidr, 8, count.index * 4 + 10)}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.availability_zones)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${element(var.availability_zones, count.index)}.${var.name}",
      "kubernetes.io/role/internal-elb", "1",
      "SubnetType", "Private"
    )
  )}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${length(var.availability_zones)}"
}

resource "aws_subnet" "storage" {
  vpc_id = "${aws_vpc.main.id}"

  # with VPC CIDR of 192.168.0.0/16 and three AZs, returns:
  # 192.168.20.0/24, 192.168.24.0/24, 192.168.28.0/24
  cidr_block = "${cidrsubnet(var.cidr, 8, count.index * 4 + 20)}"

  availability_zone = "${element(var.availability_zones, count.index)}"
  count             = "${length(var.availability_zones)}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "storage-${element(var.availability_zones, count.index)}.${var.name}",
    )
  )}"
}

resource "aws_route_table_association" "storage" {
  subnet_id      = "${element(aws_subnet.storage.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${length(var.availability_zones)}"
}
