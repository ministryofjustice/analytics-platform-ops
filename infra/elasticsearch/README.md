# Elasticsearch

We use a hosted service provided by [elastic](https://www.elastic.co) which can be managed from the [console](https://cloud.elastic.co/#/authentication/login/)

## Administration

The easiest way to administer elasticsearch itself is via the integrated __API Console__ which can be accessed once logged in to the [console](https://cloud.elastic.co/#/authentication/login/)

## Backups

It is recommended to use the __analytics-logging-backups__ `iam` user when performing backup operations

You'll need the __analytics-logging-backups__ `iam` user's access keys when working with the __s3__ backed repository

## Repository

You'll need a repository to store snapshots. For this we use an s3 backend

From the __API Console__

```json
PUT /_snapshot/repository
{
  "type": "s3",
  "settings": {
    "bucket": "bucket-name",
    "region": "eu-west-1",
    "access_key": "REDACTED",
    "secret_key": "REDACTED",
    "compress": true
  }
}
```

### Snapshot

With an existing repository, you can now create snapshots

From the __API Console__

```json
PUT /_snapshot/repository/pre-upgrade-01-01-1970 {
{
  "include_global_state": "false",
  "compress": "true",
  "server_side_encryption": "true"
}
```

### List Templates

```json
GET /_cat/templates?v&s=name
```

### List Indices

```json
GET /_cat/indices?v
```
