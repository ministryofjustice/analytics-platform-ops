import os
from string import Template

import certifi
import curator
from curator.exceptions import NoIndices
from elasticsearch import Elasticsearch
import yaml


ca_certs = certifi.where()


def handler(event, context):
    config = load_config()
    deleted_indices = {}

    for cluster in config:
        deleted_indices[cluster['name']] = prune_cluster_indices(cluster)

    return {'deleted': deleted_indices}


def load_config():

    with open('serverless-curator.yaml') as config_file:
        return yaml.load(interpolate_vars(config_file.read()))


def interpolate_vars(config):
    return Template(config).substitute(ENV=os.environ.get('ENV'))


def prune_cluster_indices(cluster):
    deleted_indices = []
    es = elasticsearch_connection(cluster['endpoint'])

    for index in cluster['indices']:
        deleted_indices.extend(prune_indices(es, index))


def elasticsearch_connection(endpoint):

    return Elasticsearch(
        endpoint,
        use_ssl=True,
        verify_certs=True,
        ca_certs=ca_certs)


def prune_indices(es, index):
    index_list = obsolete_indices(es, index)

    delete_indices(index_list)

    return index_list.working_list()


def obsolete_indices(es, index):
    index_list = curator.IndexList(es)
    index_list.filter_by_regex(kind='prefix', value=index['prefix'])
    index_list.filter_by_age(
        source='name',
        direction='older',
        timestring='%Y.%m.%d',
        unit='days',
        unit_count=index['days'])

    return index_list


def delete_indices(index_list):

    try:
        curator.DeleteIndices(index_list).do_action()

    except NoIndices:
        pass
