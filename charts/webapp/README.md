# webapp Helm Chart

Helm chart to deploy a web app with an auth proxy in front of it.
This can be a static app or a shiny app.

[Shiny](https://shiny.rstudio.com) is a web application framework for R.


## Installing the Chart

To install the chart:

```bash
$ helm install charts/webapp -f chart-env-config/ENV/webapp.yml --name webapp-APPNAME --set app.name=APPNAME --set webapp.docker.repository=YOUR_WEBAPP_DOCKER_IMAGE --set webapp.docker.tag=YOUR_WEBAPP_DOCKER_TAG --namespace apps
```

The instance will be available in <https://APPNAME.apps.ENV.mojanalytics.xyz>.

**NOTE**: Change the environment config file according to the environment
          your deploying into (the URL will change accordingly)


## Configuration

Listing only the required params here. See `/chart-env-config/` for more details.

| Parameter  | Description     | Default |
| ---------- | --------------- | ------- |
| `AuthProxy.AuthenticationRequired` | Determine if the app requires authentication | `"true"` |
| `AuthProxy.IPRanges` | Comma (,) separated list of CIDR IP ranges. When not provided the user IP is not checked. | `""` |
| `app.name` (required) | Application name. This will be part of the app URL | |
| `webapp.docker.repository` (required) | Docker image for the app | |
| `webapp.docker.tag` | Tag to use for the docker repository | `latest` |
