variable "env" {}

variable "abort_incomplete_multipart_upload_days" {
  default = 7
}

variable "backup_glacier_transition_days" {
  default = 7
}

variable "backup_expiration_days" {
  default = 30
}
