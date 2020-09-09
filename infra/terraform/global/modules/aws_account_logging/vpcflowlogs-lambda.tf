resource "null_resource" "vpcflowlogs_install_deps" {
  provisioner "local-exec" {
    command = "${path.module}/vpcflowlogs/build.sh"
  }

  triggers {
    force_rebuild = "${timestamp()}"
  }
}

data "archive_file" "vpcflowlogs_zip" {
  output_path = "/tmp/vpcflowlogs.zip"
  type        = "zip"
  source_dir  = "${path.module}/vpcflowlogs"
}

resource "aws_lambda_function" "vpcflowlogs_to_elasticsearch" {
  function_name    = "vpcflowlogs_to_elasticsearch"
  handler          = "vpcflowlogs_to_elasticsearch.lambda_handler"
  role             = "${aws_iam_role.vpcflowlogs_to_elasticsearch_role.arn}"
  runtime          = "python3.6"
  timeout          = 30
  filename         = "${data.archive_file.vpcflowlogs_zip.output_path}"
  source_code_hash = "${data.archive_file.vpcflowlogs_zip.output_base64sha256}"

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

resource "aws_lambda_permission" "allow_vpcflowlogs_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.vpcflowlogs_to_elasticsearch.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.vpcflowlogs_bucket.arn}"
}

resource "aws_s3_bucket_notification" "vpcflowlogs_object_created" {
  bucket = "${var.vpcflowlogs_s3_bucket_name}"

  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = "${aws_lambda_function.vpcflowlogs_to_elasticsearch.arn}"
    filter_prefix       = "AWSLogs/${var.account_id}/vpcflowlogs/"
  }
}
