variable "name" {
  type        = "string"
  description = "The common name given to resources"
}

variable "target_tags" {
  type        = "map"
  description = "The DLM will take a snapshot of all EBS volumes with any of these target tags"
}

variable "schedule_time" {
  type        = "string"
  default     = "00:45"
  description = "The time of day at which the DLM will run"
}

variable "schedule_interval" {
  default     = 12
  description = "The interval at which the DLM will run"
}

variable "schedule_interval_unit" {
  type        = "string"
  default     = "HOURS"
  description = "The unit of time that applies to the schedule interval"
}

variable "retain_count" {
  default     = 28
  description = "The number of snapshots to retain"
}

variable "schedule_copy_tags" {
  default     = true
  description = "Whether or not to copy tags from the targeted volume to the resulting snapshot"
}

variable "lifecycle_state" {
  type        = "string"
  default     = "ENABLED"
  description = "Whether or not to enable the DLM"
}

variable "env" {
  type        = "string"
  description = "environment name (env tag of DLM)"
}

variable "tags" {
  type        = "map"
  description = "Tags to attach to resources"
}
