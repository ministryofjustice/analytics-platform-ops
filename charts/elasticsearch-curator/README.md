# Curator Chart

Curator is a command line utility to prune old logs in elasticsearch after a specified period. This chart install Curator as a CronJob resource, to run on a regular schedule.

**This chart requires the `batch/v2alpha1` API to be enabled in the apiserver**

## Installing the Chart

To install:

```bash
$ helm install charts/elasticsearch-curator -f chart-env-config/ENV/elasticsearch-curator.yml --name=curator
```

The installation can be verified, and the next scheduled run, seen by running:

`$ kubectl get cronjobs`

## Upgrading the Chart

To upgrade:

```bash
$ helm upgrade curator charts/elasticsearch-curator -f chart-env-config/ENV/elasticsearch-curator.yml
```


## Configuration

The only parameter without a default is:

| Parameter  | Description     | Default |
| ---------- | --------------- | ------- |
| `elasticsearch.host` | ElasticSearch hostname | ``      |

Other configuration values can be viewed in `values.yml`
