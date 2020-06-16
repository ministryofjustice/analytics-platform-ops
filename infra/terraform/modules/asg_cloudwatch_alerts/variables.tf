variable "name" {
  type        = "string"
  description = "The common name given to resources"
}

variable "asg_names" {
  type        = "list"
  description = "Names of the Auto Scaling Groups to monitor"
}

variable "cpu_threshold" {
  default     = 70
  description = "High CPU usage threshold (percentage) which triggers the alert (**default `70`**)"
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

variable "alarm_actions" {
  type        = "list"
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to resources"
}

variable "desired_capacity_threshold" {
  description = "Desired Capacity threshold that triggers the alarm. If 0 then no alarms are created for desired capacity"
  default     = 0
}
