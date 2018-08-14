variable "trusted_entity" {
  type        = "list"
  description = "Trusted entity ARN to assume the instance role"
}

variable "hostedzoneid_arn" {
  type        = "list"
  description = "ARN of the hosted zone to perform the DNS01 challenge"
}

variable "role_name" {}
