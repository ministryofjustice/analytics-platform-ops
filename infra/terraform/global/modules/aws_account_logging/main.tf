variable "es_domain" {}
variable "es_port" {}
variable "es_username" {}
variable "es_password" {}

variable "es_scheme" {
  default = "https"
}

variable "cloudtrail_s3_bucket_id" {}
variable "cloudtrail_s3_bucket_arn" {}
variable "account_id" {}
variable "s3_logs_bucket_name" {}

variable "vpcflowlogs_s3_bucket_name" {}

variable "vpc_id" {}
