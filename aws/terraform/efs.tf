resource "aws_efs_file_system" "homedirs" {
  creation_token = "homedirs"
  performance_mode = "generalPurpose"

  tags {
    Name = "homedirs.${var.cluster_name}"
  }
}

resource "aws_security_group" "efs" {
  name = "efs.analytics.kops.integration.dsd.io"
  description = "Allow inbound from k8s nodes"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 2049
      to_port = 2049
      protocol = "tcp"
      security_groups = ["${var.node_security_group_id}"]
  }
}

resource "aws_efs_mount_target" "storage" {
  file_system_id = "${aws_efs_file_system.homedirs.id}"
  subnet_id = "${element(aws_subnet.storage.*.id, count.index)}"
  count = "${length(var.zones)}"
  security_groups = ["${aws_security_group.efs.id}"]
}

output "efs_dns_name" {
    value = "${aws_efs_mount_target.storage.0.dns_name}"
}
