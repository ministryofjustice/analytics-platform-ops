resource "aws_subnet" "storage" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${element(var.cidr_blocks_storage, count.index)}"
  availability_zone = "${element(var.zones, count.index)}"
  count = "${length(var.zones)}"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name = "storage-${element(var.zones, count.index)}.${var.cluster_name}"
  }
}

