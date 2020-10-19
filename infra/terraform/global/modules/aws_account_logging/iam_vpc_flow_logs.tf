# Flow Logs to S3
data "aws_iam_policy_document" "vpcflowlogs_assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [
        "vpc-flow-logs.amazonaws.com",
        "delivery.logs.amazonaws.com",
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "vpcflowlogs_policy_document" {
  statement {
    sid    = "CanLog"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
    ]

    resources = [aws_s3_bucket.vpcflowlogs_bucket.arn]
  }

  statement {
    sid       = "AWSLogDeliveryWrite"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.vpcflowlogs_bucket.arn}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "logs:CreateLogDelivery",
      "logs:DeleteLogDelivery",
    ]
  }
}

resource "aws_iam_role" "vpcflowlogs_to_elasticsearch_role" {
  name               = "vpcflowlogs_to_elasticsearch"
  assume_role_policy = data.aws_iam_policy_document.vpcflowlogs_assume_role_policy_document.json
}

resource "aws_iam_policy" "vpcflowlogs_to_elasticsearch_policy" {
  policy = data.aws_iam_policy_document.vpcflowlogs_policy_document.json
  name   = "vpcflowlogs_to_elasticsearch"
}

resource "aws_iam_role_policy_attachment" "vpcflowlogs_to_elasticsearch_policy_attachment" {
  policy_arn = aws_iam_policy.vpcflowlogs_to_elasticsearch_policy.arn
  role       = aws_iam_role.vpcflowlogs_to_elasticsearch_role.name
}

# TODO: Apply to both Alpha and Dev VPCs
# # Flow Logs to CloudWatch
# resource "aws_iam_role" "vpc_flowlogs" {
#   name_prefix        = "vpcflowlogs"
#   assume_role_policy = data.aws_iam_policy_document.vpc_flowlogs_assume.json
# }

# data "aws_iam_policy_document" "vpc_flowlogs_assume" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       identifiers = [
#         "vpc-flow-logs.amazonaws.com",
#         "delivery.logs.amazonaws.com",
#       ]

#       type = "Service"
#     }
#   }
# }

# resource "aws_iam_policy" "vpc_flowlogs" {
#   policy      = data.aws_iam_policy_document.vpc_flowlogs.json
#   name_prefix = "vpc_flow_logs"
# }

# resource "aws_iam_role_policy_attachment" "vpc_flowlogs_attachment" {
#   policy_arn = aws_iam_policy.vpc_flowlogs.arn
#   role       = aws_iam_role.vpc_flowlogs.name
# }

# data "aws_iam_policy_document" "vpc_flowlogs" {
#   statement {
#     sid       = "CanLog"
#     effect    = "Allow"
#     resources = ["arn:aws:logs:*:*:*"]

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]
#   }
# }
