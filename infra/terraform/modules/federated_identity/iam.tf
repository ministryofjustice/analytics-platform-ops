resource "aws_iam_saml_provider" "default" {
  name = "${var.env}-auth0"
  saml_metadata_document = "${file("${path.module}/saml/auth0-metadata.xml")}"
}

output "saml_provider_arn" {
  value = "${aws_iam_saml_provider.default.arn}"
}
