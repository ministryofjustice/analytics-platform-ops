resource "aws_security_group" "elb" {
  name        = "elb-${var.name}"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "elb-${var.name}"
  }

  count = "${var.use_elb}"
}

resource "aws_security_group_rule" "elb_ssh_from_cidr" {
  security_group_id = "${aws_security_group.elb.id}"

  type = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_cidr}"]

  count = "${var.use_elb}"
}

resource "aws_security_group_rule" "elb_egress" {
  security_group_id = "${aws_security_group.elb.id}"
  type = "egress"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "bastion" {
  name = "hosts-${var.name}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "hosts-${var.name}"
  }

}

resource "aws_security_group_rule" "bastion_ssh_from_elb" {
  security_group_id = "${aws_security_group.bastion.id}"
  type = "ingress"

  from_port                   = 22
  to_port                     = 22
  protocol                    = "tcp"
  source_security_group_id    = "${aws_security_group.elb.id}"

  count = "${var.use_elb}"
}

resource "aws_security_group_rule" "bastion_ssh_from_cidr" {
  security_group_id = "${aws_security_group.bastion.id}"
  type = "ingress"

  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed_cidr}"]

  count = "${var.use_elb ? "0" : "1"}"
}

resource "aws_security_group_rule" "bastion_egress" {
  security_group_id = "${aws_security_group.bastion.id}"
  type = "egress"

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_launch_configuration" "bastion" {
  name_prefix   = "${var.name}-"
  image_id      = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type = "${var.instance_type}"

  security_groups = [
    "${aws_security_group.bastion.*.id}"
  ]

  associate_public_ip_address = true
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = "${var.name}"

  vpc_zone_identifier = [
    "${var.subnet_ids}",
  ]

  desired_capacity          = "${var.num_instances}"
  min_size                  = "${var.num_instances}"
  max_size                  = "${var.num_instances}"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.bastion.name}"

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  health_check_grace_period = 0
}

resource "aws_autoscaling_attachment" "bastion" {
  autoscaling_group_name = "${aws_autoscaling_group.bastion.id}"
  elb                    = "${aws_elb.bastions.id}"
  count = "${var.use_elb}"
}

resource "aws_elb" "bastions" {
  name            = "bastion-${var.env}"
  subnets         = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.elb.id}",
  ]

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:22"
    interval            = 10
  }
  tags {
    Name              = "${var.name}"
  }

  idle_timeout = 300
  cross_zone_load_balancing = false

  count = "${var.use_elb}"
}
