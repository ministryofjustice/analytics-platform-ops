data "aws_iam_policy_document" "lambda_assume_role" {
    statement {
        actions = ["sts:AssumeRole"]
        effect = "Allow"
        principals = {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }
}
