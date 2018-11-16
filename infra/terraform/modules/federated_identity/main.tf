variable "env" {}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}

variable "oidc_client_ids" {
  type = "list"
}

variable "oidc_provider_thumbprints" {
  type = "list"
}

variable "saml_domain" {}
variable "saml_signon_url" {}
variable "saml_logout_url" {}
