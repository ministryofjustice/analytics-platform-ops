variable "trusted_entity" {
  type        = "list"
  description = "Trusted entity ARN to assume the instance role"
}

variable "hosted_zone_id" {
  description = "ID of the hosted zone to perform the DNS01 challenge"
}

variable "role_name" {}
