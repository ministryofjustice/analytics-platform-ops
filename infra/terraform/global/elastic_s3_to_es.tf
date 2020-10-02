locals {
  s3_to_es_dir = "${path.module}/assets/s3logs_to_elasticsearch"
}

module "s3logs_to_elasticsearch" {
  source  = "nozaq/lambda-auto-package/aws"
  version = "0.2.0"

  source_dir  = local.s3_to_es_dir
  output_path = "${path.module}/s3logs_to_elasticsearch.zip"

  runtime       = "python3.6"
  build_command = "cd ${local.s3_to_es_dir}; make build"

  build_triggers = {
    main         = base64sha256(file("${local.s3_to_es_dir}/s3_to_es.py"))
    requirements = base64sha256(file("${local.s3_to_es_dir}/requirements.txt"))
  }

  iam_role_name_prefix = "s3logs_to_elasticsearch"
  function_name        = "s3logs_to_elasticsearch"
  handler              = "s3_to_es.lambda_handler"
  policy_arns          = [aws_iam_policy.s3logs_to_elasticsearch.arn]
  tags                 = local.tags
  timeout              = 5

  environment = {
    variables = var.es
  }
}

resource "aws_iam_policy" "s3logs_to_elasticsearch" {
  policy = data.aws_iam_policy_document.s3logs_to_elasticsearch.json
}

data "aws_iam_policy_document" "s3logs_to_elasticsearch" {
  statement {
    sid       = "AllowSendingToSlackSnsTopic"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = ["*"]
  }
  statement {
    sid       = "GetLogEvents"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.s3_logs.arn}/*"]
  }
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.s3_logs.arn]
  }
}

resource "aws_lambda_permission" "s3logs_to_elasticsearch_cloudwatch" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.s3logs_to_elasticsearch.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.s3_logs.arn
}

resource "aws_s3_bucket_notification" "s3_logs_object_created" {
  bucket = data.aws_s3_bucket.s3_logs.id

  lambda_function {
    lambda_function_arn = module.s3logs_to_elasticsearch.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_function_event_invoke_config" "s3logs_to_elasticsearch" {
  function_name = module.s3logs_to_elasticsearch.lambda_function.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.slack.arn
    }
  }
}

data "aws_s3_bucket" "s3_logs" {
  bucket = "moj-analytics-s3-logs"
}
