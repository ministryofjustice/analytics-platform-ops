resource "aws_api_gateway_rest_api" "analytics" {
  name = "${var.env}_analytics"
}

# API Gateway stage (to give access to API from the outside)
resource "aws_api_gateway_deployment" "analytics" {
  rest_api_id = "${aws_api_gateway_rest_api.analytics.id}"
  stage_name  = "${var.env}"
  depends_on = ["aws_api_gateway_integration.post_github"]
}

# /github resource
resource "aws_api_gateway_resource" "github" {
  rest_api_id = "${aws_api_gateway_rest_api.analytics.id}"
  parent_id   = "${aws_api_gateway_rest_api.analytics.root_resource_id}"
  path_part   = "github"
}

# POST /github method
resource "aws_api_gateway_method" "post_github" {
  rest_api_id   = "${aws_api_gateway_rest_api.analytics.id}"
  resource_id   = "${aws_api_gateway_resource.github.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway -> Lambda Proxy
resource "aws_api_gateway_integration" "post_github" {
  rest_api_id = "${aws_api_gateway_rest_api.analytics.id}"
  resource_id = "${aws_api_gateway_resource.github.id}"
  http_method = "${aws_api_gateway_method.post_github.http_method}"
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.github_webhooks_handler.arn}/invocations"
  credentials = "${aws_iam_role.api_gateway_role.arn}"
}

# Role assumed by API Gateway
resource "aws_iam_role" "api_gateway_role" {
  name = "${var.env}_api_gateway_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "APIGatewayRole"
    }
  ]
}
EOF
}

# Permission to invoke lambda function
resource "aws_iam_role_policy" "api_gateway_role_policy" {
  name = "${var.env}_api_gateway_role_policy"
  role = "${aws_iam_role.api_gateway_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.github_webhooks_handler.arn}"
    }
  ]
}
EOF
}
