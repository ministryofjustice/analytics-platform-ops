resource "aws_autoscaling_group" "node" {
  depends_on           = ["null_resource.create_cluster"]
  name                 = "nodes.${var.cluster_fqdn}"
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = "${var.node_asg_max}"
  min_size             = "${var.node_asg_min}"
  desired_capacity     = "${var.node_asg_desired}"
  vpc_zone_identifier  = ["${var.vpc_private_subnet_ids}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.${var.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

data "template_file" "node_user_data" {
  template = "${file("${path.module}/data/nodeup/${var.kubernetes_version}.tpl")}"

  vars {
    cluster_fqdn          = "${var.cluster_fqdn}"
    kops_s3_bucket_id     = "${var.kops_s3_bucket_id}"
    instance_group_name   = "nodes"
    kubernetes_master_tag = ""
  }
}

resource "aws_launch_configuration" "node" {
  name_prefix          = "nodes.${var.cluster_fqdn}-"
  image_id             = "${data.aws_ami.kops_ami.id}"
  instance_type        = "${var.node_instance_type}"
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${var.node_iam_instance_profile}"

  security_groups = [
    "${aws_security_group.node.id}",
    "${var.sg_allow_ssh}",
  ]

  user_data = "${file("${path.module}/data/user_data.sh")}${data.template_file.node_user_data.rendered}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = "${var.node_volume_size}"
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_security_group" "node" {
  name        = "nodes.${var.cluster_fqdn}"
  vpc_id      = "${var.vpc_id}"
  description = "Kubernetes cluster ${var.cluster_name} nodes"

  tags = {
    KubernetesCluster = "${var.cluster_fqdn}"
    Name              = "nodes.${var.cluster_fqdn}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
