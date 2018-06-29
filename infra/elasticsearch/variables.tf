terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    bucket     = "terraform.analytics.justice.gov.uk"
    key        = "elasticsearch/terraform.tfstate"
    region     = "eu-west-1"
    encrypt    = true
    kms_key_id = "arn:aws:kms:eu-west-1:593291632749:key/df8888e3-4080-4c2b-a71e-1425e72f98e4"
  }
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.25.0"
}

variable "region" {
  default = "eu-west-1"
}

variable "name" {
  default     = "analytics-logging-backups"
  description = "The common name for the resources"
}
