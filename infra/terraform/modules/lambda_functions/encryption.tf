# Zip the lambda function before the actual deploy
data "archive_file" "encrypt_s3_object_zip" {
  type        = "zip"
  source_dir  = "${path.module}/encrypt_s3_object"
  output_path = "/tmp/encrypt_s3_object.zip"
}

# Lambda function which encrypts S3 objects
resource "aws_lambda_function" "encrypt_s3_object" {
  description      = "Encrypt S3 objects using AWS' server side encryption"
  filename         = "/tmp/encrypt_s3_object.zip"
  source_code_hash = "${data.archive_file.encrypt_s3_object_zip.output_base64sha256}"
  function_name    = "${var.env}_encrypt_${var.bucket_id}"
  role             = "${aws_iam_role.encrypt_s3_object_role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs4.3"
  timeout          = 300                                                              # 5 minutes
  depends_on       = ["data.archive_file.encrypt_s3_object_zip"]
}

# Bucket notification to trigger lambda function
resource "aws_s3_bucket_notification" "object_created" {
  bucket = "${var.bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.encrypt_s3_object.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

# Lambda role assumerole policy
data "aws_iam_policy_document" "encrypt_s3_object_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# Role running the lambda function
resource "aws_iam_role" "encrypt_s3_object_role" {
  name               = "${var.env}_${var.bucket_id}_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.encrypt_s3_object_assumerole.json}"
}

# S3 object encryption policy
data "aws_iam_policy_document" "encrypt_s3_object" {
  statement {
    sid    = "CanEncryptS3Objects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${var.bucket_arn}/*",
    ]
  }

  statement {
    sid    = "CanLog"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

# Policies for the 'encrypt_s3_object_role' role
resource "aws_iam_role_policy" "encrypt_s3_object_role_policy" {
  name = "${var.env}_encrypt_${var.bucket_id}"
  role = "${aws_iam_role.encrypt_s3_object_role.id}"

  policy = "${data.aws_iam_policy_document.encrypt_s3_object.json}"
}

# Permission to invoke the lambda function
resource "aws_lambda_permission" "allow_encrypt_s3_object_invocation" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.encrypt_s3_object.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.bucket_arn}"
}
