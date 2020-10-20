data "template_file" "cloudformation_sns_alarms_notifications" {
  vars = {
    display_name = "${var.name}-notifications"
    subscription = var.email
  }

  template = file("${path.module}/template-email-sns-stack.json.tpl")
}

resource "aws_cloudformation_stack" "notifications" {
  name          = "${var.name}-notifications"
  template_body = data.template_file.cloudformation_sns_alarms_notifications.rendered

  tags = merge(
    {
      "Name" = "${var.name}-notifications"
    },
    var.tags,
  )
}

