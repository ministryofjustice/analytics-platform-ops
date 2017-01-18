resource "aws_subnet" "rds" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.cidr_blocks_rds, count.index)}"
  availability_zone = "${element(var.zones, count.index)}"
  count = "${length(var.zones)}"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name = "rds-${element(var.zones, count.index)}.${var.cluster_name}"
  }
}

