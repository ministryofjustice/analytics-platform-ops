data "aws_autoscaling_groups" "asgs" {
  filter {
    name   = "key"
    values = ["Name", "aws:autoscaling:groupName"]
  }

  filter {
    name   = "value"
    values = ["${var.auto_scaling_groups}"]
  }
}
