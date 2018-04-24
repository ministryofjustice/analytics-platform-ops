output "region" {
    value = "${var.region}"
}

output "xyz_dns_zone_id" {
    value = "${aws_route53_zone.xyz_zone.id}"
}

output "xyz_dns_zone_name" {
    value = "${aws_route53_zone.xyz_zone.name}"
}

output "xyz_root_domain" {
    value = "${var.xyz_root_domain}"
}

output "kops_bucket_name" {
    value = "${var.kops_bucket_name}"
}

output "kops_bucket_arn" {
    value = "${aws_s3_bucket.kops_state.arn}"
}

output "kops_bucket_id" {
    value = "${aws_s3_bucket.kops_state.id}"
}

output "auth0_ses_access_key_id" {
    value = "${aws_iam_access_key.auth0_ses.id}"
}

output "auth0_ses_secret_key" {
    value = "${aws_iam_access_key.auth0_ses.secret}"
}

output "softnas_iam_role_arn" {
    value = "${aws_iam_role.softnas.arn}"
}

output "s3_logs_bucket_name" {
    value = "${module.aws_account_logging.s3_logs_bucket_name}"
}

output "hmpps_nomis_access_key_id" {
  value = "${module.hmpps_nomis_upload_user.access_key_id}"
}

output "hmpps_nomis_access_key_secret" {
  value = "${module.hmpps_nomis_upload_user.access_key_secret}"
}

output "hmpps_oasys_access_key_id" {
  value = "${module.hmpps_oasys_upload_user.access_key_id}"
}

output "hmpps_oasys_access_key_secret" {
  value = "${module.hmpps_oasys_upload_user.access_key_secret}"
}
