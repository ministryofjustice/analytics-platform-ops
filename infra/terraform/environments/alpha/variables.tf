variable "region" {
    default = "eu-west-1"
}

variable "terraform_bucket_name" {}
variable "terraform_base_state_file" {}
variable "env" {}
variable "vpc_cidr" {}
variable "availability_zones" {
    type = "list"
}

variable "softnas_ssh_public_key" {}

variable "control_panel_api_db_username" {}
variable "control_panel_api_db_password" {}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}
variable "oidc_client_ids" {
  type = "list"
}
variable "oidc_provider_thumbprints" {
  type = "list"
}
