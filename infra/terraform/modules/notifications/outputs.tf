output "github_webhooks_handler_arn" {
  value = "${aws_lambda_function.github_webhooks_handler.arn}"
}
