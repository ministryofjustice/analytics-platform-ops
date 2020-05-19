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
  default     = 70
  description = "High CPU usage threshold (percentage) which triggers the alert (**default `70`**)"
}

variable "cpu_low_threshold" {
  default     = 5
  description = "Low CPU usage threshold (percentage) which triggers the alert (**default `5`**)"
}

variable "email" {
  type        = "string"
  description = "email address where alerts are sent to"
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to resources"
}
