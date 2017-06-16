### Environment variables

| Name           | Description                                         | Default                   |
| -------------- | --------------------------------------------------- | ------------------------- |
| `GITHUB_ORG`   | Organisation to migrate                             | `moj-analytical-services` |
| `GITHUB_TOKEN` | GigHub "Personal access token" used to authenticate |                           |
| `STAGE`        | Environment, e.g. `dev`, `alpha`, etc...            | `dev`                     |

### Execution

```bash
$ STAGE=dev GITHUB_TOKEN=$YOUR_TOKEN ./github_to_aws_migration.py
```

**NOTE**: `github_to_aws_migration.py` needs to be executable

### AWS Authentication

boto3 (the Python AWS client) will authenticate to AWS using the [usual
methods](http://docs.aws.amazon.com/cli/latest/topic/config-vars.html#credentials).

### Operation performed

- For each of the organization members it will create the corresponding IAM
  role (invoking the `create_user_role` lambda function)
- For each of the teams will:
  - Create the team S3 bucket (invoking the `create_team_bucket` lambda function)
  - Create the team S3 bucket's IAM policies (invoking the
    `create_team_bucket_policies` lambda function)
  - Get the list of team members and for each of them:
    - attach the team IAM policy to this members' IAM role (invoking the
      `attach_bucket_policy` lambda function)

### Required permissions

#### GitHub

The GitHub personal token needs the `read:org` scope (under `admin:org`)

#### AWS

The user used to authenticate needs to be able to invoke these lambda functions.
