data "aws_ami" "softnas" {
  most_recent = true

  filter {
    name   = "name"
    values = ["SoftNAS Cloud Meter*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["aws-marketplace"]
  }

  # SoftNAS account ID
  owners = ["679593333241"]
}

resource "aws_key_pair" "softnas" {
  key_name   = "${var.env}-softnas"
  public_key = "${var.ssh_public_key}"
}

resource "aws_security_group" "softnas" {
  name        = "${var.env}-softnas"
  description = "Allow NFS from cluster and HTTP from SSH bastions"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${var.node_security_group_id}"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "udp"
    security_groups = ["${var.node_security_group_id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = ["${var.bastion_security_group_id}"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-softnas"
  }
}

resource "aws_network_interface" "softnas_eth0" {
  subnet_id       = "${element(var.subnet_ids, count.index)}"
  security_groups = ["${aws_security_group.softnas.id}"]

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-softnas-${count.index}-eth0"
  }
}

resource "aws_network_interface" "softnas_eth1" {
  subnet_id       = "${element(var.subnet_ids, count.index)}"
  security_groups = ["${aws_security_group.softnas.id}"]

  # required for SoftNAS "VirtualIP" to work correctly
  source_dest_check = false

  count = "${var.num_instances}"

  tags {
    Name = "${var.env}-softnas-${count.index}-eth1"
  }
}

resource "aws_instance" "softnas" {
  ami                  = "${data.aws_ami.softnas.id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${aws_key_pair.softnas.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.softnas.name}"

  count = "${var.num_instances}"

  network_interface {
    network_interface_id = "${element(aws_network_interface.softnas_eth0.*.id, count.index)}"
    device_index         = 0
  }

  network_interface {
    network_interface_id = "${element(aws_network_interface.softnas_eth1.*.id, count.index)}"
    device_index         = 1
  }

  tags {
    Name = "${var.env}-softnas-${count.index}"
  }
}
