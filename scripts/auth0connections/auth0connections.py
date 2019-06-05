#!/usr/bin/env python
import base64
import functools
from collections import defaultdict
from pathlib import Path
from pprint import pprint

import click
import yaml
from auth0.v3.management import Auth0
from environs import Env
from jinja2 import Environment

env = Env()
env.read_env()  # read .env file, if it exists
jinja_env = Environment()
jinja_env.filters["base64enc"] = lambda x: base64.urlsafe_b64encode(
    x.encode("utf8")
).decode()


AUTH0_TOKEN = env("AUTH0_TOKEN")
AUTH0_DOMAIN = env("AUTH0_DOMAIN")


@functools.lru_cache(maxsize=1)
def get_client():
    return Auth0(AUTH0_DOMAIN, AUTH0_TOKEN)


def render_local_connections(config):
    connections = {}
    connections_root = Path(__file__).cwd() / Path("connections")
    connection_dirs = [entry for entry in connections_root.iterdir() if entry.is_dir()]

    for connection in connection_dirs:
        connection_name = connection.stem
        scripts = connection.glob("*.js")
        script_templates = {
            x.stem: jinja_env.from_string(x.open(encoding="utf8").read())
            for x in scripts
        }
        scripts_rendered = {}
        for name, template in script_templates.items():
            scripts_rendered[name] = template.render(**config.get(connection_name))

        with (connection / Path("config.yaml")).open("r") as connection_config:
            yaml_rendered = jinja_env.from_string(connection_config.read()).render(
                **config.get(connection_name)
            )
            body = yaml.safe_load(yaml_rendered) or defaultdict(dict)
            body["options"]["scripts"] = scripts_rendered
            connections[connection_name] = body

    return connections


@click.group()
@click.pass_context
@click.option("-f", "--config-file", type=click.File("r"), required=True)
def cli(ctx, config_file):
    ctx.ensure_object(dict)
    ctx.obj["config_file"] = yaml.safe_load(config_file)
    config_file.close()


@cli.command()
def remote():
    """
    Show a list of existing connections on auth0
    """
    click.echo("Remote connections:")
    client = get_client()
    click.echo(yaml.safe_dump(client.connections.all()))


@cli.command()
@click.pass_context
def local(ctx):
    """
    Show defined connections
    """
    click.echo("Local connections:")
    click.echo(yaml.safe_dump(render_local_connections(ctx.obj["config_file"])))


@cli.command()
@click.pass_context
def create(ctx):
    click.echo("Creating connections:")
    rendered_connections = render_local_connections(ctx.obj["config_file"])
    client = get_client()
    remote_connections = [x["name"] for x in client.connections.all()]
    for connection_name, body in rendered_connections.items():
        if not connection_name in remote_connections:
            click.echo(f"Creating {connection_name}")
            resp = client.connections.create(body)
            click.echo(pprint(resp))
        else:
            click.echo(
                f"Skipping: {connection_name} as it already exists. Delete it "
                f"from auth0 if you want this script to recreate it"
            )


if __name__ == "__main__":
    cli()
