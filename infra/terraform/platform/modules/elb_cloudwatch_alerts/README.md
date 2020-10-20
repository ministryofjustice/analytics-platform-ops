# CloudWatch Alerts

##### Terraform module to enable CloudWatch alerts for an ELB

Sends alerts when one more hosts are not healthy and when the surge queue is over a certain length.

Usage
-----

Create the CloudWatch alerts for the specified ELB

```hcl-terraform
module "kubenetes_master_monitoring" {
  source = "../modules/elb_cloudwatch_alerts"

  name               = "${terraform.workspace}-kubenetes-master-alerts"
  elb_name           = "${var.kubenetes_master_elb_name}"
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
| `elb_name`            (**Required**) | `string` | Names of the ELB to monitor |
| `alarm_actions`       (**Required**) | `list`   | List of ARNS of resources for alerts to be sent to |
| `tags`                (**Required**) | `map`    | Tags to attach to resources |
