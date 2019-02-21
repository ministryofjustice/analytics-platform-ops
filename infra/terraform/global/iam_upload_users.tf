module "hmpps_nomis_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "nomis"
}

module "hmpps_oasys_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "oasys"
}

module "hmpps_prisonss_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "hmpps"
  system_name       = "prison-selfservice"
}

module "laa_cla_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.uploads.arn}"
  org_name          = "laa"
  system_name       = "cla"
}

module "lookup_upload_user" {
  source = "../modules/data_upload_user"

  upload_bucket_arn = "${aws_s3_bucket.lookups.arn}"
  org_name          = "ap"
  system_name       = "lookup"
}
