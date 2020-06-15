output "stack_notifications_arn" {
  value = "${aws_cloudformation_stack.notifications.outputs["ARN"]}"
}
