variable "name" {
  type        = "string"
  description = "The common name given to resources"
}

variable "ec2_instance_names" {
  type        = "list"
  description = "Names of the EC2 instances to monitor"
}

variable "ec2_instance_ids" {
  type        = "list"
  description = "IDs of the EC2 instances to monitor"
}

variable "cpu_threshold" {
  default     = 80
  description = "CPU usage threashold (percentage) which triggers the alert (**default `80`**)"
}

variable "email" {
  type        = "string"
  description = "email address where alerts are sent to"
}

variable "component" {
  type        = "string"
  description = "component which is monitored, e.g. SoftNAS"
}

variable "env" {
  type        = "string"
  description = "environment name (env tag of DLM)"
}

variable "is_production" {
  description = "whether is a production environment (is-production tag of DLM)"
}

variable "tags" {
  type        = "map"
  description = "Tags for DLM"

  default = {
    business-unit = "Platforms"
    application   = "analytical-platform"
    owner         = "analytical-platform:analytics-platform-tech@digital.justice.gov.uk"
  }
}
