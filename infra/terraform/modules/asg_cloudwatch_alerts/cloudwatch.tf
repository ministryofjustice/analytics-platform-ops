resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  count             = "${length(var.asg_names)}"
  alarm_name        = "${var.name}_${element(var.asg_names, count.index)}-cpu-usage-alarm"
  alarm_description = "This metric monitors the CPU Usage of the EC2 instances in an Autoscaling group."

  dimensions = {
    AutoScalingGroupName = "${element(var.asg_names, count.index)}"
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
  alarm_actions   = ["${var.alarm_actions}"]

  tags = "${var.tags}"
}
