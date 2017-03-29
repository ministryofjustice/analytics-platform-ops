# shiny-app Helm Chart

[Shiny](https://shiny.rstudio.com) is a web application framework for R.


## Installing the Chart

To install an rstudio instance for the user specified in the Username variable (Github username):

```bash
$ helm install charts/shiny-app -f chart-env-config/ENV/shiny-app.yml --name shiny-app-APPNAME --set app.name=APPNAME --set gitSync.repository=https://github.com/YOUR/REPO --namespace default
```

The instance will be available in <https://APPNAME.apps.ENV.mojanalytics.xyz>.

**NOTE**: The repository needs to contain a `/shiny-server` directory.

**NOTE**: Change the environment config file to deploy in a
          different environment (the URL will change accordingly)


## Configuration

Listing only the required params here. See `/chart-env-config/` for more details.

| Parameter  | Description     | Default |
| ---------- | --------------- | ------- |
| `app.name` (required) | Application name. This will be part of the app URL | |
| `gitSync.repository` (required) | Git repository URL. The shiny app is in the `/shiny-server` directory | |
