variable "region" {
  default = "eu-west-1"
}

variable "terraform_bucket_name" {}

variable "terraform_global_state_file" {
  default = "base/terraform.tfstate"
}

variable "vpc_cidr" {}

variable "availability_zones" {
  type        = "list"
  description = "VPC AZs. Minimum of 2 required due to RDS's requirement for > 1 AZ. Define 3 AZs for a HA production environment"

  default = [
    "eu-west-1a",
    "eu-west-1b",
  ]
}

# Auth0 tenant URLs MUST end with a trailing slash
variable "oidc_provider_url" {}

variable "oidc_client_id" {}

variable "kubernetes_oidc_client_id" {
  description = "Client ID of Auth0 application used by Kubernetes cluster"
}

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
  type        = "list"
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

variable "kube_cpu_reserved" {
  description = "Amount of CPU reserved for kubernetes processes on nodes"
  type        = "string"
}

variable "kube_memory_reserved" {
  description = "Amount of memory reserved for kubernetes processes on nodes"
  type        = "string"
}

variable "kube_storage_reserved" {
  description = "Amount of Storage reserved for kubernetes processes on nodes"
  type        = "string"
}

variable "system_cpu_reserved" {
  description = "Amount of CPU reserved for system processes on nodes"
  type        = "string"
}

variable "system_memory_reserved" {
  description = "Amount of memory reserved for system processes on nodes"
  type        = "string"
}

variable "system_storage_reserved" {
  description = "Amount of storage reserved for system processes on nodes"
  type        = "string"
}
