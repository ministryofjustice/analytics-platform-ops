# CloudWatch Alerts

##### Terraform module to enable CloudWatch alerts for an Auto Scaling Group

Sends alerts when CPU usage goes above ${cpu_threshold} percent.

Usage
-----

Create the CloudWatch alerts for the specified ELB

```hcl-terraform
module "kubenetes_master_monitoring" {
  source = "../modules/asg_cloudwatch_alerts"

  name               = "${terraform.workspace}-kubenetes-master-alerts"
  asg_names          = "${var.kubenetes_master_asg_names}"
  alarm_actions      = ["${module.softnas_monitoring.stack_notifications_arn}"]

  tags = "${merge(map(
    "component", "Kubenetes",
  ), var.tags)}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `name`                (**Required**) | `string` | Name of the resources |
| `asg_names`            (**Required**) | `string` | Names of the ELB to monitor |
| `alarm_actions`       (**Required**) | `list`   | List of ARNS of resources for alerts to be sent to |
| `tags`                (**Required**) | `map`    | Tags to attach to resources |
