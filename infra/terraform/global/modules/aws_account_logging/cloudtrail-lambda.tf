# Install dependencies
resource "null_resource" "cloudtrail_install_deps" {
  provisioner "local-exec" {
    command = "${path.module}/cloudtrail/build.sh"
  }

  triggers {
    force_rebuild = "${timestamp()}"
  }
}

# Zip the lambda function before the actual deploy
data "archive_file" "cloudtrail_zip" {
  type        = "zip"
  source_dir  = "${path.module}/cloudtrail"
  output_path = "/tmp/cloudtrail.zip"

  depends_on = ["null_resource.cloudtrail_install_deps"]
}

# Lambda function to ship Cloudtrail logs to Elasticsearch cluster
resource "aws_lambda_function" "cloudtrail_to_elasticsearch" {
  description      = "Ships Cloudtrail logs to Elasticsearch"
  filename         = "/tmp/cloudtrail.zip"
  source_code_hash = "${data.archive_file.cloudtrail_zip.output_base64sha256}"
  function_name    = "cloudtrail_to_elasticsearch"
  role             = "${aws_iam_role.cloudtrail_to_elasticsearch.arn}"
  handler          = "cloudtrail_to_es.lambda_handler"
  runtime          = "python3.6"
  timeout          = 30
  depends_on       = ["data.archive_file.cloudtrail_zip"]

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
resource "aws_lambda_permission" "allow_cloudtrail_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudtrail_to_elasticsearch.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.cloudtrail_s3_bucket_arn}"
}

# Trigger Lambda function from S3 object created event
resource "aws_s3_bucket_notification" "cloudtrail_object_created" {
  bucket = "${var.cloudtrail_s3_bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.cloudtrail_to_elasticsearch.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/${var.account_id}/CloudTrail/"
  }
}
