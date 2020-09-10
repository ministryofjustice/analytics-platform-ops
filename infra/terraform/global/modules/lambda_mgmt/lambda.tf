resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  filename         = var.zipfile
  handler          = var.handler
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.lambda_runtime
  source_code_hash = var.source_code_hash
  count            = local.enabled
  timeout          = var.timeout
  tags             = var.tags

  environment {
    variables = var.environment_variables
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = local.enabled
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[0].function_name
  principal     = "events.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudWatch"
  source_arn    = aws_cloudwatch_event_rule.lambda_cloud_watch_rule[0].arn
}
