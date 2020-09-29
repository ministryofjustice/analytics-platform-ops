variable "es_domain" {
  type = string
}

variable "es_port" {
  type = string
}

variable "es_username" {
  type = string
}

variable "es_password" {
  type = string
}

variable "es_scheme" {
  type    = string
  default = "https"
}

variable "cloudtrail_s3_bucket_id" {
  type = string
}

variable "cloudtrail_s3_bucket_arn" {
  type = string
}

variable "account_id" {
  type = string
}

variable "s3_logs_bucket_name" {
  type = string
}

variable "vpcflowlogs_s3_bucket_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources"
}
