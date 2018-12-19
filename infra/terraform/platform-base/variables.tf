variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {}

variable "terraform_global_state_file" {
  default = "base/terraform.tfstate"
}

variable "vpc_cidr" {}

variable "availability_zones" {
  description = "VPC AZs. Minimum of 2 required due to RDS's requirement for > 1 AZ. Define 3 AZs for a HA production environment"

  default = [
    "eu-west-1a",
    "eu-west-1b",
  ]
}

variable "oidc_provider_domain" {}

variable "oidc_provider_thumbprints" {
  type = "list"
}

variable "idp_saml_domain" {}
variable "idp_saml_signon_url" {}
variable "idp_saml_logout_url" {}
variable "idp_saml_x509_cert" {}

variable "k8s_version" {}
variable "k8s_instancegroup_image" {}

variable "k8s_availability_zones" {
  description = "AZs for the Kubernetes cluster to span. Must be 1 or 3 AZs"

  default = [
    "eu-west-1a",
  ]
}

variable "k8s_masters_machine_type" {
  default = "t2.medium"
}

variable "k8s_masters_root_volume_size" {
  default = 64
}

variable "k8s_nodes_machine_type" {
  default = "t2.medium"
}

variable "k8s_nodes_root_volume_size" {
  default = 64
}

variable "k8s_nodes_instancegroup_min_size" {
  default = 1
}

variable "k8s_nodes_instancegroup_max_size" {
  default = 1
}

variable "k8s_highmem_nodes_machine_type" {
  default = "t2.medium"
}

variable "k8s_highmem_nodes_root_volume_size" {
  default = 64
}

variable "k8s_highmem_nodes_instancegroup_min_size" {
  default = 0
}

variable "k8s_highmem_nodes_instancegroup_max_size" {
  default = 0
}

variable "k8s_bastions_machine_type" {
  default = "t2.micro"
}

variable "k8s_bastions_root_volume_size" {
  default = 32
}

variable "k8s_bastions_instancegroup_min_size" {
  default = 1
}

variable "k8s_bastions_instancegroup_max_size" {
  default = 1
}

variable "github_oauth_client_id" {}
variable "github_oauth_client_secret" {}

variable "auth0_api_client_id" {}
variable "auth0_api_client_secret" {}

variable "aws_account_id" {}
