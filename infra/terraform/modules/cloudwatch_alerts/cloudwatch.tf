resource "aws_cloudwatch_metric_alarm" "cpu_threshold" {
  count             = "${length(var.ec2_instance_names)}"
  alarm_name        = "${var.name}_${element(var.ec2_instance_names, count.index)}-cpu-alarm"
  alarm_description = "This metric monitors EC2 CPU utilisation"

  dimensions = {
    InstanceId = "${element(var.ec2_instance_ids, count.index)}"
  }

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "${var.cpu_threshold}"
  period              = "${var.period}"
  evaluation_periods  = "${var.evaluation_periods}"
  datapoints_to_alarm = "${var.datapoints_to_alarm}"
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
  statistic           = "Average"
  comparison_operator = "LessThanThreshold"
  threshold           = "${var.cpu_low_threshold}"
  period              = "${var.period}"
  evaluation_periods  = "${var.evaluation_periods}"
  datapoints_to_alarm = "${var.datapoints_to_alarm}"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${ aws_cloudformation_stack.notifications.outputs["ARN"] }"]

  tags = "${var.tags}"
}

# alert if an EC2 instance becomes unhealthy for more than 1 period of time
resource "aws_cloudwatch_metric_alarm" "health_monitoring" {
  count             = "${length(var.ec2_instance_names)}"
  alarm_name        = "${var.name}_${element(var.ec2_instance_names, count.index)}-unhealthy"
  alarm_description = "This metric monitors EC2 health status"

  dimensions = {
    InstanceId = "${element(var.ec2_instance_ids, count.index)}"
  }

  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "2"
  period              = "${var.period}"
  evaluation_periods  = "${var.evaluation_periods}"
  datapoints_to_alarm = "${var.datapoints_to_alarm}"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${ aws_cloudformation_stack.notifications.outputs["ARN"] }"]

  tags = "${var.tags}"
}
