resource "aws_cloudwatch_metric_alarm" "cpu_threshold" {
  count             = "${length(var.ec2_instance_names)}"
  alarm_name        = "${var.name}_${element(var.ec2_instance_names, count.index)}-cpu-alarm"
  alarm_description = "This metric monitors EC2 CPU utilisation"

  dimensions = {
    InstanceId = "${element(var.ec2_instance_ids, count.index)}"
  }

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "${var.cpu_threshold}"
  period              = "300"                           # 5 minutes
  evaluation_periods  = "3"
  datapoints_to_alarm = "2"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${ aws_cloudformation_stack.notifications.outputs["ARN"] }"]

  tags = "${var.tags}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_threshold" {
  count             = "${length(var.ec2_instance_names)}"
  alarm_name        = "${var.name}_${element(var.ec2_instance_names, count.index)}-cpu-low-alarm"
  alarm_description = "This metric monitors low EC2 CPU utilisation"

  dimensions = {
    InstanceId = "${element(var.ec2_instance_ids, count.index)}"
  }

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Maximum"
  comparison_operator = "LessThanThreshold"
  threshold           = "${var.cpu_low_threshold}"
  period              = "300"                           # 5 minutes
  evaluation_periods  = "3"
  datapoints_to_alarm = "2"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${ aws_cloudformation_stack.notifications.outputs["ARN"] }"]

  tags = "${var.tags}"
}
