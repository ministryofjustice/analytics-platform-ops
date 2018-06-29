resource "aws_db_instance" "db" {
  identifier = "${var.instance_name}"
  name       = "${var.db_name}"
  username   = "${var.username}"
  password   = "${var.password}"

  allocated_storage = "${var.allocated_storage}"
  instance_class    = "${var.instance_class}"
  storage_type      = "${var.storage_type}"

  engine                     = "postgres"
  engine_version             = "9.6"
  auto_minor_version_upgrade = true

  db_subnet_group_name   = "${aws_db_subnet_group.subnet.name}"
  vpc_security_group_ids = ["${aws_security_group.sg.*.id}"]

  skip_final_snapshot     = false
  backup_retention_period = 35
  backup_window           = "22:00-23:59"
  maintenance_window      = "Sun:06:00-Sun:08:00"

  tags {
    Name = "${var.instance_name}"
  }
}

resource "aws_security_group" "sg" {
  name   = "${var.instance_name}"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = ["${var.node_security_group_id}"]
  }
}

resource "aws_db_subnet_group" "subnet" {
  name       = "${var.instance_name}"
  subnet_ids = ["${var.subnet_ids}"]
}
