// Lambda function which encrypts S3 objects
resource "aws_lambda_function" "encrypt_s3_object" {
    description = "Encrypt S3 objects using AWS' server side encryption"
    filename = "encrypt_s3_object.zip"
    function_name = "encrypt_s3_object"
    role = "${aws_iam_role.encrypt_s3_object_role.arn}"
    handler = "index.handler"
    runtime = "nodejs4.3"
}

// Bucket notification to trigger lambda function
resource "aws_s3_bucket_notification" "object_created_in_scratch" {
    bucket = "${var.bucket_id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.encrypt_s3_object.arn}"
        events = ["s3:ObjectCreated:*"]
    }
}

// Role running the lambda function
resource "aws_iam_role" "encrypt_s3_object_role" {
    name = "encrypt_s3_object_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CanEncryptS3Objects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${var.bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

// Permission to invoke the lambda function
resource "aws_lambda_permission" "allow_encrypt_s3_object_invocation" {
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.encrypt_s3_object.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "${var.bucket_arn}"
}
