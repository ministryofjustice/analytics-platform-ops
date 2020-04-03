#!/usr/bin/env python
import base64
import functools
from collections import defaultdict
from pathlib import Path
from pprint import pprint
import sys

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
    '''Returns full connection dicts, from the connections listed in the config
    file, and rendered using the template specified.
    
    Uses a template specified in the connection config
    e.g. 'template_name: hmpps-auth' in the connection configuration
         means use the template in: ./connection_templates/hmmps-auth/
    '''
    connections = {}
    template_root = Path(__file__).cwd() / Path("connection_templates")
    template_dirs = dict((entry.stem, entry) for entry in template_root.iterdir() if entry.is_dir())

    for connection_name in config:
        connection = config[connection_name]
        connection['name'] = connection_name
        template_name = connection['connection_template']
        try:
            template_path = template_dirs[template_name]
        except KeyError:
            print(f'template_name: "{template_name}" is specified in the config, but no such template exists in {template_root}')
            sys.exit(1)

        # render the scripts
        scripts = template_path.glob("*.js")
        script_templates = {
            x.stem: jinja_env.from_string(x.open(encoding="utf8").read())
            for x in scripts
        }
        scripts_rendered = {}
        for name, script_template in script_templates.items():
            scripts_rendered[name] = script_template.render(**connection)

        # render the main connection template
        with (template_path / Path("config.yaml")).open("r") as config_yaml_file:
            yaml_rendered = jinja_env.from_string(config_yaml_file.read()).render(
                **connection
            )
            body = yaml.safe_load(yaml_rendered) or defaultdict(dict)
            # add in the rendered scripts
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
@click.option('--names', '-n', help='Only print each connection\'s name', is_flag=True)
def remote(names):
    """
    Show a list of existing connections on auth0
    """
    click.echo("Remote connections:")
    client = get_client()
    if names:
        click.echo(yaml.safe_dump(
            [c['name'] for c in client.connections.all()]
        ))
    else:
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
            if resp:
                click.echo(pprint(resp))
        else:
            click.echo(
                f"Skipping: {connection_name} as it already exists. Delete it "
                f"from auth0 if you want this script to recreate it"
            )


@cli.command()
@click.pass_context
@click.argument('name')
def delete(ctx, name):
    click.echo(f"Deleting connection {name}")
    client = get_client()
    remote_connections = dict((c["name"], c) for c in client.connections.all())
    try:
        connection_id = remote_connections[name]['id']
    except KeyError:
        click.echo(f"Error: Connection {name} does not exist (remotely)", err=True)
        sys.exit(1)
    resp = client.connections.delete(connection_id)
    if resp:
        click.echo(pprint(resp))


if __name__ == "__main__":
    cli()
