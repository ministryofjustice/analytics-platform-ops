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

variable "softnas_ssh_public_key" {}

variable "softnas_num_instances" {
  default = 2
}

variable "softnas_default_volume_size" {
  default = 10
}

variable "softnas_ami_id" {
  default = "ami-6498ac02"
}

variable "softnas_instance_type" {
  default = "m4.large"
}

variable "control_panel_api_db_username" {}
variable "control_panel_api_db_password" {}

variable "airflow_db_username" {}
variable "airflow_db_password" {}

variable "ses_ap_email_identity_arn" {}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}

variable "oidc_client_ids" {
  type = "list"
}

variable "oidc_provider_thumbprints" {
  type = "list"
}

variable "trusted_entity" {
  type        = "list"
  description = "Cert-Manager: Trusted entity ARN to assume the instance role"
}

variable "hostedzoneid_arn" {
  type        = "list"
  description = "Cert-Manager: ARN of the hosted zone to perform the DNS01 challenge"
}
