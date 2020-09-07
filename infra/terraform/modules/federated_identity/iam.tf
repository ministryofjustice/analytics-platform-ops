data "template_file" "saml_metadata" {
  template = "${file("${path.module}/saml/idp-metadata.xml")}"

  vars {
    saml_domain     = "${var.saml_domain}"
    saml_signon_url = "${var.saml_signon_url}"
    saml_logout_url = "${var.saml_logout_url}"
    saml_x509_cert  = "${var.saml_x509_cert}"
  }
}

resource "aws_iam_saml_provider" "idp" {
  name                   = "${terraform.workspace}-auth0"
  saml_metadata_document = "${data.template_file.saml_metadata.rendered}"
}

output "saml_provider_arn" {
  value = "${aws_iam_saml_provider.idp.arn}"
}

resource "aws_iam_openid_connect_provider" "idp" {
  url             = "${var.oidc_provider_url}"
  client_id_list  = ["${var.oidc_client_id}"]
  thumbprint_list = ["${var.oidc_provider_thumbprints}"]
}

output "oidc_provider_arn" {
  value = "${aws_iam_openid_connect_provider.idp.arn}"
}
