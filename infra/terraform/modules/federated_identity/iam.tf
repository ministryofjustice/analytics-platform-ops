resource "aws_iam_saml_provider" "auth0" {
  name = "${var.env}-auth0"
  saml_metadata_document = "${file("${path.module}/saml/${var.env}-auth0-metadata.xml")}"
}

output "saml_provider_arn" {
  value = "${aws_iam_saml_provider.auth0.arn}"
}
