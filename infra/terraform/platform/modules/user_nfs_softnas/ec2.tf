resource "aws_key_pair" "softnas" {
  key_name   = "${terraform.workspace}-${var.name_identifier}"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "softnas" {
  name        = "${terraform.workspace}-${var.name_identifier}"
  description = "Allow NFS from cluster and HTTP from SSH bastions"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "udp"
    security_groups = [var.node_security_group_id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = [var.bastion_security_group_id]
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

  tags = merge(
    {
      "Name" = "${terraform.workspace}-softnas"
    },
    var.tags,
  )
}

resource "aws_network_interface" "softnas_eth0" {

  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.softnas.id]

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-eth0"
    },
    var.tags,
  )
}

resource "aws_network_interface" "softnas_eth1" {
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.softnas.id]

  # required for SoftNAS "VirtualIP" to work correctly
  source_dest_check = false

  count = var.num_instances

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}-eth1"
    },
    var.tags,
  )
}

resource "aws_instance" "softnas" {
  ami                  = var.softnas_ami_id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.softnas.key_name
  iam_instance_profile = aws_iam_instance_profile.softnas.name
  monitoring           = var.monitoring

  count = var.num_instances

  network_interface {
    network_interface_id = element(aws_network_interface.softnas_eth0.*.id, count.index)
    device_index         = 0
  }

  network_interface {
    network_interface_id = element(aws_network_interface.softnas_eth1.*.id, count.index)
    device_index         = 1
  }

  tags = merge(
    {
      "Name" = "${terraform.workspace}-${var.name_identifier}-${count.index}"
    },
    var.tags,
  )
}

