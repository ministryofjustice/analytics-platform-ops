variable "name" {
  type        = string
  description = "The common name given to resources"
}

variable "ec2_instance_names" {
  type        = list(string)
  description = "Names of the EC2 instances to monitor"
}

variable "ec2_instance_ids" {
  type        = list(string)
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
  type        = string
  description = "email address where alerts are sent to"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to resources"
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  default     = 3
}

