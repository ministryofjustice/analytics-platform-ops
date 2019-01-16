variable "instance_role_name" {
  type        = "list"
  description = "The Instance Role to attach the policy to"
}

variable "policy_name" {}

variable "auto_scaling_groups" {
  type = "list"
}
