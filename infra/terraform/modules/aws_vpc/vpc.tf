resource "aws_vpc" "main" {
    cidr_block = "${var.cidr}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"

    # Terraform does not support variable interpolation in key names,
    # so map() is used as a workaround.
    # See: https://github.com/hashicorp/terraform/issues/14516
    tags = "${map("Name", "${var.name}", "KubernetesCluster", "${var.name}", "kubernetes.io/cluster/${var.name}", "shared")}"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"

    tags = "${map("Name", "${var.name}", "kubernetes.io/cluster/${var.name}", "shared")}"
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
