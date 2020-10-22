variable "oidc_provider_url" {
  description = "Provider URL. Must end with a trailing slash"
}

variable "oidc_client_id" {
}

variable "oidc_provider_thumbprints" {
  type = list(string)
}

variable "saml_domain" {
}

variable "saml_signon_url" {
}

variable "saml_logout_url" {
}

variable "saml_x509_cert" {
}

