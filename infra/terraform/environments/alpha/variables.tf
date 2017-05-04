variable "region" {
    default = "eu-west-1"
}

variable "terraform_bucket_name" {}
variable "terraform_base_state_file" {}
variable "env" {}
variable "vpc_cidr" {}
variable "availability_zones" {
    type = "list"
}

variable "sns_arn" {}
variable "gh_hook_secret" {}
