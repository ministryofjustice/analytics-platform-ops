resource "aws_iam_role_policy" "cloudtrail_to_elasticsearch" {
  name   = "cloudtrail_to_elasticsearch"
  role   = aws_iam_role.cloudtrail_to_elasticsearch.id
  policy = data.aws_iam_policy_document.cloudtrail_to_elasticsearch.json
}

data "aws_iam_policy_document" "cloudtrail_to_elasticsearch" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
  }
  statement {
    effect    = "Allow"
    resources = [var.cloudtrail_s3_bucket_arn]
    actions   = ["s3:ListBucket"]
  }
  statement {
    effect    = "Allow"
    resources = ["${var.cloudtrail_s3_bucket_arn}/*"]
    actions   = ["s3:GetObject"]
  }
}
