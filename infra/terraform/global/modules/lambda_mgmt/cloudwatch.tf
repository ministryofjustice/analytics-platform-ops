# CloudWatch event rule to schedule event
resource "aws_cloudwatch_event_rule" "lambda_cloud_watch_rule" {
  name                = "${var.lambda_function_name}"
  schedule_expression = "${var.schedule_expression}"
  count               = "${var.enabled}"
}

# CloudWatch event target to set rule target to lambda function
resource "aws_cloudwatch_event_target" "lambda_cloud_watch_target" {
  target_id = "${var.lambda_function_name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
  rule      = "${aws_cloudwatch_event_rule.lambda_cloud_watch_rule.name}"
  count     = "${var.enabled}"
}
