resource "aws_api_gateway_rest_api" "analytics" {
  name = "${var.env}_analytics"
}

# API Gateway stage (to give access to API from the outside)
resource "aws_api_gateway_deployment" "analytics" {
  rest_api_id = "${aws_api_gateway_rest_api.analytics.id}"
  stage_name  = "api"
  depends_on = ["aws_api_gateway_integration.post_github"]
}
