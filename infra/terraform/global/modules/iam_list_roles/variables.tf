variable "org_name" {
  type        = string
  description = "Organisation name"
}

variable "system_name" {
  type        = string
  description = "System name"
}

variable "tags" {
  type = map(string)
}
