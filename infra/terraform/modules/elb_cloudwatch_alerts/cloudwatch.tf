resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  alarm_name        = "${var.name}_${var.elb_name}-healthy-hosts-alarm"
  alarm_description = "This metric monitors the number of Healthy hosts in an ELB"

  dimensions = {
    LoadBalancerName = "${var.elb_name}"
  }

  namespace           = "AWS/ELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  comparison_operator = "LessThanThreshold"
  threshold           = "${var.healthy_host_threshold}"
  period              = "${var.period}"
  evaluation_periods  = "${var.evaluation_periods}"
  datapoints_to_alarm = "${var.datapoints_to_alarm}"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${var.alarm_actions}"]

  tags = "${var.tags}"
}

resource "aws_cloudwatch_metric_alarm" "surge_queue_length" {
  alarm_name        = "${var.name}_${var.elb_name}-surge-queue-length-alarm"
  alarm_description = "This metric monitors the size of the ELB surge queue"

  dimensions = {
    LoadBalancerName = "${var.elb_name}"
  }

  namespace           = "AWS/ELB"
  metric_name         = "SurgeQueueLength"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "${var.surge_queue_length_threshold}"
  period              = "${var.period}"
  evaluation_periods  = "${var.evaluation_periods}"
  datapoints_to_alarm = "${var.datapoints_to_alarm}"
  treat_missing_data  = "breaching"

  actions_enabled = "true"
  alarm_actions   = ["${var.alarm_actions}"]

  tags = "${var.tags}"
}
