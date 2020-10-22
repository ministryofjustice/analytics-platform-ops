data "aws_caller_identity" "current" {
}

data "aws_route53_zone" "main" {
  name = "mojanalytics.xyz"
}

variable "kops_bucket_name" {
    type = string
    description = "name of the bucket where KOPS state is stored"
}
