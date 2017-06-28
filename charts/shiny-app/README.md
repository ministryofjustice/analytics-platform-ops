# shiny-app Helm Chart

[Shiny](https://shiny.rstudio.com) is a web application framework for R.


## Installing the Chart

To install an rstudio instance for the user specified in the Username variable (Github username):

```bash
$ helm install charts/shiny-app -f chart-env-config/ENV/shiny-app.yml --name shiny-app-APPNAME --set app.name=APPNAME --set shinyApp.docker.repository=YOUR_SHINY_APP_DOCKER_IMAGE --set shinyApp.docker.tag=YOUR_SHINY_APP_DOCKER_TAG --namespace apps
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
| `shinyApp.docker.repository` (required) | Docker image with the shiny server/app | |
| `shinyApp.docker.tag` | Tag to use for the docker repository | `latest` |
