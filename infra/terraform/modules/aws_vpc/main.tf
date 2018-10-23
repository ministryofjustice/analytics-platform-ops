variable "name" {}
variable "cidr" {}

variable "availability_zones" {
  type = "list"
}

variable "dmz_cidr_blocks" {
  type = "list"

  default = [
    "192.168.0.0/24",
    "192.168.4.0/24",
    "192.168.8.0/24",
  ]
}

variable "private_cidr_blocks" {
  type = "list"

  default = [
    "192.168.10.0/24",
    "192.168.14.0/24",
    "192.168.18.0/24",
  ]
}

variable "storage_cidr_blocks" {
  type = "list"

  default = [
    "192.168.20.0/24",
    "192.168.24.0/24",
    "192.168.28.0/24",
  ]
}
