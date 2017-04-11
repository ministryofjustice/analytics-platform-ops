variable "env" {}


output "source_bucket_arn" {
    value = "${aws_s3_bucket.source.arn}"
}

output "scratch_bucket_arn" {
    value = "${aws_s3_bucket.scratch.arn}"
}

output "logs_bucket_arn" {
    value = "${aws_s3_bucket.logs.arn}"
}

output "iam_managers_arn" {
    value = "${aws_iam_group.managers.arn}"
}

output "iam_analysts_arn" {
    value = "${aws_iam_group.analysts.arn}"
}

output "scratch_bucket_id" {
    value = "${aws_s3_bucket.scratch.id}"
}

output "shared_analyst_access_key_id" {
  value = "${aws_iam_access_key.shared_analyst.id}"
}

output "shared_analyst_access_key_secret" {
  value = "${aws_iam_access_key.shared_analyst.secret}"
}

# CREST bucket

output "crest_bucket_arn" {
    value = "${aws_s3_bucket.crest.arn}"
}

output "crest_bucket_id" {
    value = "${aws_s3_bucket.crest.id}"
}
