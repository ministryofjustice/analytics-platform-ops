# Install dependencies
resource "null_resource" "s3logs_install_deps" {
  provisioner "local-exec" {
    command = "${path.module}/s3logs/build.sh"
  }

  triggers {
    force_rebuild = "${timestamp()}"
  }
}

# Zip the lambda function before the actual deploy
data "archive_file" "s3logs_zip" {
  type        = "zip"
  source_dir  = "${path.module}/s3logs"
  output_path = "/tmp/s3logs.zip"

  depends_on = ["null_resource.s3logs_install_deps"]
}

# Lambda function to ship S3 access logs to Elasticsearch cluster
resource "aws_lambda_function" "s3_logs_to_elasticsearch" {
  description      = "Ships s3 access logs to Elasticsearch"
  filename         = "/tmp/s3logs.zip"
  source_code_hash = "${data.archive_file.s3logs_zip.output_base64sha256}"
  function_name    = "s3_logs_to_elasticsearch"
  role             = "${aws_iam_role.s3_logs_to_elasticsearch.arn}"
  handler          = "s3_to_es.lambda_handler"
  runtime          = "python3.6"
  timeout          = 5
  depends_on       = ["data.archive_file.s3logs_zip"]

  environment {
    variables = {
      ES_DOMAIN   = "${var.es_domain}"
      ES_PORT     = "${var.es_port}"
      ES_SCHEME   = "${var.es_scheme}"
      ES_USERNAME = "${var.es_username}"
      ES_PASSWORD = "${var.es_password}"
    }
  }
}

# Allow Lambda function to be invoked from S3 event
resource "aws_lambda_permission" "allow_s3_logs_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.s3_logs_to_elasticsearch.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_logs.arn}"
}

# Trigger Lambda function from S3 object created event
resource "aws_s3_bucket_notification" "s3_logs_object_created" {
  bucket = "${aws_s3_bucket.s3_logs.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.s3_logs_to_elasticsearch.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
