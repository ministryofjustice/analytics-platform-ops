terraform {
  backend "s3" {
    bucket               = "terraform.analytics.justice.gov.uk"
    workspace_key_prefix = "platform:"
    key                  = "terraform.tfstate"
    region               = "eu-west-1"
  }
}

provider "aws" {
  region  = var.region
  version = "~> 2.45"
}

