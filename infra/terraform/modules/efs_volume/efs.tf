resource "aws_efs_file_system" "fs" {
  creation_token   = "${var.name}"
  performance_mode = "${var.performance_mode}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "sg" {
  name        = "${var.name}"
  description = "Allow inbound from k8s nodes"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${var.node_security_group_id}"]
  }
}

resource "aws_efs_mount_target" "mount_target" {
  file_system_id  = "${aws_efs_file_system.fs.id}"
  subnet_id       = "${element(var.subnet_ids, count.index)}"
  security_groups = ["${aws_security_group.sg.id}"]
  count           = "${var.num_subnets}"
}
