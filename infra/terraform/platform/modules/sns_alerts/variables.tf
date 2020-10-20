variable "name" {
  type        = string
  description = "The common name given to resources"
}

variable "email" {
  type        = string
  description = "email address where alerts are sent to"
}

variable "tags" {
  type        = map(string)
  description = "Tags to attach to resources"
}

