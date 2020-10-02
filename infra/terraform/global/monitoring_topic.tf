resource "aws_sns_topic" "slack" {
  name_prefix       = "slack"
  display_name      = "slack"
  kms_master_key_id = "alias/aws/sns"
  tags              = local.tags
}

resource "aws_sns_topic_policy" "slack" {
  arn    = aws_sns_topic.slack.arn
  policy = data.aws_iam_policy_document.slack.json
}

data "aws_iam_policy_document" "slack" {
  policy_id = "__default_policy_ID"

  statement {
    sid       = "__default_statement_ID"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
