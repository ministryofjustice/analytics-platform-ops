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

variable "lookups_bucket_name" {
  default = "moj-analytics-lookup-tables"
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

variable "create_etcd_ebs_snapshot_env_vars" {
  default = {
    TAG_KEY            = "etcd"
    TAG_VALUE          = "1"
    INSTANCE_TAG_KEY   = "k8s.io/role/master"
    INSTANCE_TAG_VALUE = "1"
  }
}

variable "prune_etcd_ebs_snapshot_env_vars" {
  default = {
    SNAPSHOT_TAG_KEY   = "etcd"
    SNAPSHOT_TAG_VALUE = "1"
    DAYS_OLD           = "14"
  }
}

variable "vpcflowlogs_s3_bucket_name" {
  default = "moj-analytics-global-vpcflowlogs"
}

variable "vpc_id" {}

variable "environment_variables" {
  type        = "map"
  description = "Empty Placeholder variable to be overrided when using the lambda_mgmt module"
  default     = {}
}
