# Create the Lambda function with environment variables for filtering or config
resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.lambda_function_name}"
  filename         = "${var.zipfile}"
  handler          = "${var.handler}"
  role             = "${aws_iam_role.lambda_role.arn}"
  runtime          = "${var.lambda_runtime}"
  source_code_hash = "${var.source_code_hash}"
  count            = "${var.enabled}"
  timeout          = "${var.timeout}"
  environment {
    variables {
      INSTANCE_KEY   = "${var.instance_tag_key}"
      INSTANCE_VALUE = "${var.instance_tag_value}"
    }
  }
}

# Lambda permission to allow cloudwatch to invoke lambda function
resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "events.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudWatch"
  count         = "${var.enabled}"
  source_arn    = "${aws_cloudwatch_event_rule.lambda_cloud_watch_rule.arn}"
}
