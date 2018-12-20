variable "auth0_api_client_id" {}
variable "auth0_api_client_secret" {}

variable "auth0_rules" {
  type = "list"
}

variable "auth0_rules_config" {
  type = "map"
}

variable "auth0_tenant_domain" {}
variable "aws_account_id" {}
variable "env" {}
variable "github_oauth_client_id" {}
variable "github_oauth_client_secret" {}

variable "github_orgs" {
  type = "list"
}

variable "google_domains" {
  type = "list"
}

variable "mfa_disabled_ip_ranges" {
  type = "list"
}

variable "root_domain" {}
