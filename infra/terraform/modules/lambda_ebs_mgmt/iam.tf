# Assume role policy to allow lambda to assume role
data "aws_iam_policy_document" "lambda_snapshot_assume" {
  "statement" {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

# Lambda policy to attach to lambda_role
resource "aws_iam_policy" "lambda_policy" {
  policy = "${var.lamda_policy}"
}

# The role which the lambda service will assume
resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_snapshot_assume.json}"
}

# Attaching the lambda_policy to ebs_create_snapshot role
resource "aws_iam_role_policy_attachment" "lambda_snapshot_attatchment" {
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
  role       = "${aws_iam_role.lambda_role.name}"
}
