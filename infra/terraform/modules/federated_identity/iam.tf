
resource "aws_iam_openid_connect_provider" "auth0" {
  url             = "${var.oidc_provider_url}"
  client_id_list  = ["${var.oidc_client_ids}"]
  thumbprint_list = ["${var.oidc_provider_thumbprints}"]
}

output "oidc_provider_arn" {
  value = "${aws_iam_openid_connect_provider.auth0.arn}"
}
