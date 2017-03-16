# Charts installation

After the cluster is set up you can install the following charts
by running these commands from the root of the project (change `dev` to your environment name).

**[Helm](https://github.com/kubernetes/helm)** is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

1. Install helm (see link for instructions)
2. Run `$ helm init`


## nginx-ingress

Necessary to access the services from outside the cluster.

```bash
$ helm install charts/nginx-ingress -f chart-env-config/dev/nginx-ingress.yml --namespace kube-system --name cluster-ingress
```


## node-exporter

Exports metrics about the kubernetes nodes.

```bash
$ helm install charts/node-exporter --namespace kube-system --name node-metrics
```


## heapster

Exports metrics about the kubernetes nodes (used by k8s when describing pods, etc...)

```bash
$ helm install charts/heapster --namespace kube-system --name heapster
```


## kube-dashboard

Kubernetes dashboard.

Available at http://dashboard.services.dev.mojanalytics.xyz

```bash
$ helm install charts/kube-dashboard -f chart-env-config/dev/kube-dashboard.yml --namespace default --name cluster-dashboard
```


## fluentd

Reads the logs and sends them to ElasticSearch/Kibana.

```bash
$ helm install charts/fluentd -f chart-env-config/dev/fluentd.yml --namespace kube-system --name cluster-logging
```


## kibana-auth-proxy

Grant (authorised) access to the Kibana to view the logs. Kibana is hosted with ElasticSearch in AWS.

Available at https://kibana.services.dev.mojanalytics.xyz/_plugin/kibana

```bash
$ helm install charts/kibana-auth-proxy -f chart-env-config/dev/kibana.yml --namespace kube-system --name cluster-logviewer
```


## prometheus

Collects metrics, monitor systems and can send alerts.

```bash
$ helm install stable/prometheus -f chart-env-config/dev/prometheus.yml --namespace kube-system --name cluster-metrics
```


## grafana

Analytics and monitoring interface.

Available at https://grafana.services.dev.mojanalytics.xyz

```bash
$ helm install stable/grafana -f chart-env-config/dev/grafana.yml --namespace kube-system --name cluster-monitoring
```


## init-platform

Creates k8s resources related to the users homes (AWS EFS).

```bash
$ helm install charts/init-platform -f chart-env-config/dev/init-platform.yml --namespace default --name init-platform
```


## jenkins

Control panel with jobs to set up users and spawn analysys platforms.

Available at https://jenkins.services.dev.mojanalytics.xyz

```bash
$ helm install stable/jenkins -f chart-env-config/dev/jenkins.yml --namespace default --name control-panel
```
