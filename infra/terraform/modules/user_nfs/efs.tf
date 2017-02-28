resource "aws_efs_file_system" "users" {
  creation_token = "${var.env}-users"
  performance_mode = "generalPurpose"

  tags {
    Name = "users.${var.cluster_name}"
  }
}

resource "aws_security_group" "efs" {
  name = "efs.${var.cluster_name}"
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
  file_system_id = "${aws_efs_file_system.users.id}"
  subnet_id = "${element(var.subnet_ids, count.index)}"
  security_groups = ["${aws_security_group.efs.id}"]
  count = "${length(var.availability_zones)}"
}
