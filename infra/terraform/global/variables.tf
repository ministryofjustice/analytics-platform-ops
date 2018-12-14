variable "region" {
  default = "eu-west-1"
}

variable "kops_bucket_name" {}
variable "platform_root_domain" {}
variable "es_domain" {}
variable "es_port" {}
variable "es_username" {}
variable "es_password" {}

variable "es_scheme" {
  default = "https"
}

variable "uploads_bucket_name" {
  default = "mojap-land"
}

variable "global_cloudtrail_bucket_name" {
  default = "moj-analytics-global-cloudtrail"
}

variable "s3_logs_bucket_name" {
  default = "moj-analytics-s3-logs"
}

variable "helm_repo_s3_bucket_name" {
  default = "moj-analytics-helm-repo"
}

variable "vpc_availability_zones" {
  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c",
  ]
}

variable "vpc_private_subnets_cidr_blocks" {
  default = [
    "10.0.1.0/24", 
    "10.0.2.0/24", 
    "10.0.3.0/24"
  ]
}

variable "vpc_public_subnets_cidr_blocks"  {
  default = [
    "10.0.101.0/24", 
    "10.0.102.0/24", 
    "10.0.103.0/24"
  ]
}

variable "atlantis_github_user_token" {}
