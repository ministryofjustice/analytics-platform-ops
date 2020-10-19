data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_to_elasticsearch" {
  name               = "cloudtrail_to_elasticsearch"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}
