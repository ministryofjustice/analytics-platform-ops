resource "aws_iam_user" "jenkinsci" {
  name = "${terraform.workspace}-jenkinsci"
}

resource "aws_iam_access_key" "jenkinsci" {
  user = "${aws_iam_user.jenkinsci.name}"
}

resource "aws_iam_user_policy" "jenkinsci" {
  name = "${terraform.workspace}-jenkinsci"
  user = "${aws_iam_user.jenkinsci.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:CreateRepository"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
