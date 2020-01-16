# EBS Snapshots

##### Terraform module to provision [DLM (Data Lifecycle Management) Policies)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/snapshot-lifecycle.html)

Usage
-----

Create DLM Policy to snapshot ebs volumes on a schedule

```hcl-terraform
module "ebs_snapshots" {
  source = "../modules/ebs_snapshots"

  name        = "${var.env}-dlm"

  target_tags = {
    env = "${var.env}"
  }
}
```

Parameters
-----------
| Name                                 | Type         | Description                               |
| ------------------------------------ | ------------ | ----------------------------------------- |
| `name`                (**Required**) | `string`     | The common name given to resources        |
| `target_tags`         (**Required**) | `map`        | The DLM will take a snapshot of all EBS volumes with any of these target tags |
| `schedule_interval`                  | `int`        | The interval at which the dlm will run (**default `12`**) |
| `schedule_interval_unit`             | `string`     | The unit of time that applies to the schedule interval (**default `HOURS`**) |
| `schedule_time`                      | `string`     | The time of day at which the dlm will run (**default `00:45`**) |
| `retain_count`                    | `int`        | The number of snapshots to retain (**default `28`**) |
| `schedule_copy_tags`                 | `boolean`    | Whether or not to copy tags from the targeted volume to the resulting snapshot (**default `true`**)|
| `lifecycle_enabled`                  | `string`     | Whether or not to enable the DLM, can be `"ENABLED"` or `"DISABLED"` (**default `"ENABLED"`**) |
