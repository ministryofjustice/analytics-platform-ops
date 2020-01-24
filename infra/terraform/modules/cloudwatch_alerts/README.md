# CloudWatch Alerts

##### Terraform module to enable CloudWatch alerts

Sends alerts when CPU usage goes above ${cpu_threshold} percent.

Usage
-----

Create the CloudWatch alerts for the specified EC2 instances

```hcl-terraform
module "softnas_monitoring" {
  source = "../modules/cloudwatch_alerts"

  name               = "${terraform.workspace}-softnas-alerts"
  ec2_instance_ids   = "${module.user_nfs_softnas.ec2_instance_ids}"
  ec2_instance_names = "${module.user_nfs_softnas.ec2_instance_names}"
  cpu_threshold      = 80
  email         = "analytics-platform-tech@digital.justice.gov.uk"

  component     = "SoftNAS"
  env           = "${terraform.workspace}"
  is_production = "${var.is_production}"
}
```

Parameters
-----------
| Name                                 | Type     | Description                               |
| ------------------------------------ | -------- | ----------------------------------------- |
| `name`                (**Required**) | `string` | Name of the resources |
| `ec2_instance_names`  (**Required**) | `list`   | Names of the EC2 instances to monitor |
| `ec2_instance_ids`    (**Required**) | `list`   | IDs of the EC2 instances to monitor |
| `env`                 (**Required**) | `string` | Environment name. It will be used as value for the `env` tag |
| `is_production`       (**Required**) | `string` | Whether is a production environment. Can be `false` or `true`. It will be used as value for the `is-production` tag value |
| `email`                              | `string` | email address where alerts are sent to |
| `cpu_threshold`                      | `number` | CPU usage threashold (percentage) which triggers the alert (**default `80`**) |
