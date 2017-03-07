# RStudio Helm Chart


## Installing the Chart

To install an rstudio instance for the user specified in the Username variable (Github username):

```bash
$ helm install charts/rstudio -f chart-env-config/ENV/rstudio.yml --set Username=USERNAME --namespace user-USERNAME --name=USERNAME-rstudio
```

The instance will be available in <https://USERNAME-rstudio.tools.ENV.mojanalytics.xyz>.

**NOTE**: Change the environment config file to deploy in a different environment
          (the URL will change accordingly)


## Upgrading the Chart

To upgrade a user rstudio chart:
```bash
$ helm upgrade USERNAME-rstudio charts/rstudio -f chart-env-config/ENV/rstudio.yml --set Username=USERNAME
```


## Configuration

Listing only the required params here. See `/chart-env-config/` for more
details.

| Parameter  | Description     | Default |
| ---------- | --------------- | ------- |
| `Username` | Github username | ``      |
