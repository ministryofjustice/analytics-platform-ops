output "s3_logs_bucket_name" {
  value = "${aws_s3_bucket.s3_logs.id}"
}
