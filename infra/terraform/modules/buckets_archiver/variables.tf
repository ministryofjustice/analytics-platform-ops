variable "env" {
  type        = "string"
  description = "environment name"
}

variable "name" {
  type        = "string"
  description = "name of the 'archived buckets' bucket"
}

variable "logging_bucket_name" {
  type        = "string"
  description = "name of the bucket where logging for the 'archived buckets' bucket will go"
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to the bucket"
}

variable "region" {
  type        = "string"
  description = "Region where the S3 bucket will be created"
}

variable "k8s_worker_role_arn" {
  type        = "string"
  description = "ARN of the IAM role of the kubernetes workers. Used to allow them to assume 'buckets_archiver' role"
}

variable "expiration_days" {
  description = "number of days after which the objects (and the older versions) will be deleted"
  default     = 183
}
