
# # data "aws_iam_policy_document" "vpcflowlogs_assume_role_policy_document" {
# #   statement {
# #     effect  = "Allow"
# #     actions = ["sts:AssumeRole"]

# #     principals {
# #       identifiers = [
# #         "vpc-flow-logs.amazonaws.com",
# #         "delivery.logs.amazonaws.com",
# #         "lambda.amazonaws.com",
# #       ]

# #       type = "Service"
# #     }
# #   }
# # }

# data "aws_iam_policy_document" "vpcflowlogs" {
#   statement {
#     sid    = "AWSLogDeliveryAclCheck"
#     effect = "Allow"

#     actions = [
#       "s3:ListBucket",
#       "s3:GetBucketAcl",
#       "s3:GetBucketPolicy",
#       "s3:PutBucketPolicy",
#     ]

#     resources = [data.aws_s3_bucket.vpcflowlogs_bucket.arn]
#   }

#   statement {
#     sid    = "AWSLogDeliveryWrite"
#     effect = "Allow"

#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "logs:CreateLogDelivery",
#       "logs:DeleteLogDelivery",
#     ]

#     resources = ["${aws_s3_bucket.vpcflowlogs_bucket.arn}/*"]
#   }
# }

# resource "aws_iam_role" "vpcflowlogs_to_elasticsearch_role" {
#   name               = "vpcflowlogs_to_elasticsearch"
#   assume_role_policy = data.aws_iam_policy_document.vpcflowlogs_assume_role_policy_document.json
# }

# resource "aws_iam_policy" "vpcflowlogs_to_elasticsearch_policy" {
#   policy = data.aws_iam_policy_document.vpcflowlogs_policy_document.json
#   name   = "vpcflowlogs_to_elasticsearch"
# }

# resource "aws_iam_role_policy_attachment" "vpcflowlogs_to_elasticsearch_policy_attachment" {
#   policy_arn = aws_iam_policy.vpcflowlogs_to_elasticsearch_policy.arn
#   role       = aws_iam_role.vpcflowlogs_to_elasticsearch_role.name
# }

# data "aws_s3_bucket" "vpcflowlogs_bucket" {
#   bucket = "moj-analytics-global-vpcflowlogs"
# }
