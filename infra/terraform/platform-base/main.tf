terraform {
  backend "s3" {
    bucket               = "terraform.analytics.justice.gov.uk"
    workspace_key_prefix = "platform-base:"
    key                  = "terraform.tfstate"
    region               = "eu-west-1"
  }
}

provider "aws" {
  region  = var.region
  version = "~> 3"
}

module "aws_vpc" {
  source = "./modules/aws_vpc"

  name               = "${terraform.workspace}.${var.platform_root_domain}"
  cidr               = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "cluster_dns" {
  source = "./modules/cluster_dns"

  root_zone_name   = var.platform_root_domain
  root_zone_domain = var.platform_root_domain
  root_zone_id     = data.aws_route53_zone.main.id
}

module "federated_identity" {
  source = "./modules/federated_identity"

  oidc_provider_url         = var.oidc_provider_url
  oidc_client_id            = var.oidc_client_id
  oidc_provider_thumbprints = var.oidc_provider_thumbprints
  saml_domain               = var.idp_saml_domain
  saml_signon_url           = var.idp_saml_signon_url
  saml_logout_url           = var.idp_saml_logout_url
  saml_x509_cert            = var.idp_saml_x509_cert
}

module "kops_spec" {
  source = "./modules/kops_spec"

  k8s_version       = var.k8s_version
  kops_state_bucket = var.kops_bucket_name

  vpc_id                            = module.aws_vpc.vpc_id
  vpc_cidr                          = module.aws_vpc.cidr
  availability_zones                = var.k8s_availability_zones
  public_subnet_ids                 = module.aws_vpc.dmz_subnet_ids
  public_subnet_cidr_blocks         = module.aws_vpc.dmz_subnet_cidr_blocks
  public_subnet_availability_zones  = module.aws_vpc.dmz_subnet_availability_zones
  private_subnet_ids                = module.aws_vpc.private_subnet_ids
  private_subnet_cidr_blocks        = module.aws_vpc.private_subnet_cidr_blocks
  private_subnet_availability_zones = module.aws_vpc.private_subnet_availability_zones

  cluster_dns_name = module.cluster_dns.dns_zone_domain
  cluster_dns_zone = module.cluster_dns.dns_zone_id

  oidc_client_id  = var.kubernetes_oidc_client_id
  oidc_issuer_url = var.oidc_provider_url

  instancegroup_image = var.k8s_instancegroup_image

  masters_extra_sg_id      = module.aws_vpc.extra_master_sg_id
  masters_machine_type     = var.k8s_masters_machine_type
  masters_root_volume_size = var.k8s_masters_root_volume_size

  nodes_extra_sg_id            = module.aws_vpc.extra_node_sg_id
  nodes_machine_type           = var.k8s_nodes_machine_type
  nodes_instancegroup_min_size = var.k8s_nodes_instancegroup_min_size
  nodes_instancegroup_max_size = var.k8s_nodes_instancegroup_max_size
  nodes_root_volume_size       = var.k8s_nodes_root_volume_size

  highmem_nodes_machine_type           = var.k8s_highmem_nodes_machine_type
  highmem_nodes_instancegroup_min_size = var.k8s_highmem_nodes_instancegroup_min_size
  highmem_nodes_instancegroup_max_size = var.k8s_highmem_nodes_instancegroup_max_size
  highmem_nodes_root_volume_size       = var.k8s_highmem_nodes_root_volume_size

  bastions_extra_sg_id            = module.aws_vpc.extra_bastion_sg_id
  bastions_machine_type           = var.k8s_bastions_machine_type
  bastions_instancegroup_min_size = var.k8s_bastions_instancegroup_min_size
  bastions_instancegroup_max_size = var.k8s_bastions_instancegroup_max_size
  bastions_root_volume_size       = var.k8s_bastions_root_volume_size

  kube_cpu_reserved       = var.kube_cpu_reserved
  kube_memory_reserved    = var.kube_memory_reserved
  kube_storage_reserved   = var.kube_storage_reserved
  system_cpu_reserved     = var.system_cpu_reserved
  system_memory_reserved  = var.system_memory_reserved
  system_storage_reserved = var.system_storage_reserved
}
