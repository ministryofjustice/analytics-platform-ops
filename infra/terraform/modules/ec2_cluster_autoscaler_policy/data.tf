data "aws_autoscaling_groups" "nodes" {
  filter {
    name   = "key"
    values = ["Name", "aws:autoscaling:groupName"]
  }

  filter {
    name   = "value"
    values = ["${var.instance_role_name}"]
  }
}
