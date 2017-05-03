terraform {
  backend "s3" {
    bucket = "terraform.analytics.justice.gov.uk"
    key    = "base/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}
