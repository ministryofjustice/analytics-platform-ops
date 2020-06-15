# CloudWatch Alerts

##### Terraform module to create SNS topic to send alerts to

Create an SNS topic and subscribe the email address to it.

Usage
-----

Create the CloudWatch alerts for the specified EC2 instances

```hcl-terraform
module "sns_alert_topic" {
  source = "../modules/sns_alerts"

  name  = "${terraform.workspace}-softnas-alerts"
  email = "analytics-platform-tech@digital.justice.gov.uk"
  tags  = "${var.tags}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `name`                (**Required**) | `string` | Name of the resources |
| `email`               (**Required**) | `string` | email address where alerts are sent to |
| `tags`                (**Required**) | `map`    | Tags to attach to resources |
