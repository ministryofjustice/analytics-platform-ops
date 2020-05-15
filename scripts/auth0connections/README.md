# Auth0 Connection Creator Script

This script creates Auth0 connections that are defined as YAML config that
references a connection template in the `./connection_templates` directory.

This should really be done in `terraform` using the auth0 provider, but this has
already been attempted and couldn't be done as it requires all `apps/clients` linked to
the connection to be managed by `terraform` too. We allow clients to be created by the
`cpanel` so every time we ran a terraform apply it would go and delete any `cpanel`
created `apps/clients`.

This script isn't ideal but I feel it's better than just providing instructions
about where to click in the auth0 UI or trying to PR the auth0 provider to support
what we need it to do.

## Running

### Commands

#### Preparation

Before running the commands you need to setup your environment like this:

```bash
cd analytics-platform-ops/scripts/auth0connections
# Get API key from: https://manage.auth0.com/dashboard/eu/dev-analytics-moj/apis/management/explorer
export AUTH0_TOKEN=eyJ...
export AUTH0_DOMAIN=dev-analytics-moj.eu.auth0.com
```

(See Environment Variables for more info)

#### `local`

Prints what Auth0 connections are defined locally - i.e. in the specified YAML
and [`./connection_templates`](./connection_templates).

example:

```bash
poetry run ./auth0connections.py -f ~/ap/analytics-platform-config/chart-env-config/dev/auth0connections.yaml local
```

#### `remote`

Prints what Auth0 connections are defined on Auth0

example:

```bash
poetry run ./auth0connections.py -f ~/ap/analytics-platform-config/chart-env-config/dev/auth0connections.yaml remote
```

#### `create`

Creates on Auth0 the connections that are defined locally, using the Auth0
management API.

Does not overwrite connections of the same name - delete a connection if
 you wish to overwrite it.

example:

```bash
poetry run ./auth0connections.py -f ~/ap/analytics-platform-config/chart-env-config/dev/auth0connections.yaml create
```

## Environment Variables

`AUTH0_TOKEN` - An auth0 management v3 API token for you tenant, you can get one
by visiting this page: [https://manage.auth0.com/#/apis/management/explorer](https://manage.auth0.com/#/apis/management/explorer).

`AUTH0_DOMAIN` - Domain of your auth0 tenant.

Feel free to give it a short TTL as it will only be required while you
run this script.

### Create `.env` file

If you put the environment variables in an `.env` file then using Docker will be
easier.

```
AUTH0_TOKEN=eyJ…oeafmoaeo
AUTH0_DOMAIN=your-auth0-domain.eu.auth0.com
```

## Values

See the [example values file](./values.example.yaml) for the values you need to provide when creating a
client.

### With Docker

#### Build

```bash
docker build . -t a0c
```

#### Execute Script

```bash
 docker run --env-file=.env -v ../../../analytics-platform-config/chart-env-config/dev/auth0connections.yaml:/tmp/config.yaml a0c local
```

### Without Docker

Make sure you have [`poetry` installed](https://poetry.eustace.io/docs/#installation) then run:

```bash
poetry install
poetry run ./auth0connections.py -f path/to/values.yaml COMMAND
```

## Specify Connections

To define a new connection:

-   make a directory under [`./connections`](./connections)
-   in that directory make a file called `config.yaml` with json body of
    your connection. You can use jinja templating to interpolate variables from the `values.yaml`
    file.
-   (optional) If you want to make embed a javacript file in the `options.script` part of your connection,
    e.g. a `fetchUserProfile.js` script for an `oauth2` connection then create a file called `fetchUserProfile.js` alongside
    the config.yaml. You can also interpolate values using `jinja2` syntax here. See the [nomis](./connections/nomis)
    for a real example.
