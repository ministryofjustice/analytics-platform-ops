module "hmcts_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "hmcts"
  system_name       = "azure"
}

module "hmpps_nomis_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "nomis"
}

module "hmpps_oasys_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "oasys"
}

module "hmpps_prisonss_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "prison-selfservice"
}

module "hmpps_prisoner_money_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "prisoner-money"
}

module "laa_cla_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "laa"
  system_name       = "cla"
}

module "ppas_mdt_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "ppas"
  system_name       = "mdt"
}

module "ppas_workforce_planning_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${data.aws_s3_bucket.uploads.arn}"
  org_name          = "ppas"
  system_name       = "workforce-planning"
}

module "lookup_upload_user" {
  source = "../modules/data_bucket_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.lookups.arn}"
  system_name       = "lookup"
}

data "aws_s3_bucket" "uploads" {
  bucket = "mojap-land"
}
