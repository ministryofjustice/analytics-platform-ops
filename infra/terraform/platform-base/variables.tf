variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {}

variable "terraform_global_state_file" {
  default = "base/terraform.tfstate"
}

variable "vpc_cidr" {}

variable "availability_zones" {
  type = "list"
}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}

variable "oidc_client_id" {}

variable "oidc_provider_thumbprints" {
  type = "list"
}

variable "idp_saml_domain" {}
variable "idp_saml_signon_url" {}
variable "idp_saml_logout_url" {}
variable "idp_saml_x509_cert" {}

variable "k8s_version" {}
variable "k8s_instancegroup_image" {}

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
