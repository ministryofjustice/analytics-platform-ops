variable "asg_arn" {
  type        = "list"
  description = "ARN of the autoscaling group the Kubernetes worker nodes belong to"
}

variable "instance_role_name" {
  type        = "list"
  description = "The Instance Role to attach the policy to"
}

variable "policy_name" {}
