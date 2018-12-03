variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {}

variable "terraform_base_state_file" {
  default = "base/terraform.tfstate"
}

variable "vpc_cidr" {}

variable "availability_zones" {
  type = "list"
}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}

variable "oidc_client_ids" {
  type = "list"
}

variable "oidc_provider_thumbprints" {
  type = "list"
}

variable "idp_saml_domain" {}
variable "idp_saml_signon_url" {}
variable "idp_saml_logout_url" {}
variable "idp_saml_x509_cert" {}
