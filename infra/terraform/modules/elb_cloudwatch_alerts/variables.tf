variable "name" {
  type        = "string"
  description = "The common name given to resources"
}

variable "elb_name" {
  type        = "string"
  description = "Names of the ELB to monitor"
}

variable "healthy_host_threshold" {
  default     = 1
  description = "Healthy host threshold which triggers the alert (**default `1`**)"
}

variable "surge_queue_length_threshold" {
  default     = 5
  description = "Surge queue length threshold which triggers the alert (**default `5`**)"
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  default     = 60
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  default     = 3
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  default     = 2
}

variable "alarm_actions" {
  type        = "list"
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to resources"
}
