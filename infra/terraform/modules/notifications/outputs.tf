output "github_webhooks_handler_arn" {
  value = "${aws_lambda_function.github_webhooks_handler.arn}"
}

output "organization_events_topic_arn" {
  value = "${aws_sns_topic.github_organization_events.arn}"
}

output "membership_events_topic_arn" {
  value = "${aws_sns_topic.github_membership_events.arn}"
}

output "team_events_topic_arn" {
  value = "${aws_sns_topic.github_team_events.arn}"
}
