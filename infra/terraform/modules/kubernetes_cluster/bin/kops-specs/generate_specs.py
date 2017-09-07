#!/usr/bin/env python3
import argparse
import json
import pprint
import os

import yaml


def str_presenter(dumper, data):
  if len(data.splitlines()) > 1:  # check for multiline string
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
  return dumper.represent_scalar('tag:yaml.org,2002:str', data)

yaml.add_representer(str, str_presenter)


parser = argparse.ArgumentParser()

parser.add_argument('--template-path', nargs='?', required=True)
parser.add_argument('--out-path', nargs='?', required=True)
parser.add_argument('--cluster-name', nargs='?', required=True)
parser.add_argument('--vpc-id', nargs='?', required=True)
parser.add_argument('--state-bucket', nargs='?', required=True)
parser.add_argument('--kubernetes-version', nargs='?', required=True)
parser.add_argument('--dns-zone', nargs='?', required=True)
parser.add_argument('--zones', nargs='?', required=True)
parser.add_argument('--network-cidr', nargs='?', required=True)
parser.add_argument('--node-instance-type', nargs='?', required=True)
parser.add_argument('--node-count', type=int, nargs='?', required=True)
parser.add_argument('--node-volume-size', type=int, nargs='?', required=True)
parser.add_argument('--ami-name', nargs='?', required=True)
parser.add_argument('--bastion-instance-type', nargs='?', required=True)
parser.add_argument('--bastion-count', type=int, nargs='?', required=True)
parser.add_argument('--master-instance-type', nargs='?', required=True)
parser.add_argument('--public-subnet-zones', type=json.loads, nargs='?',
                    required=True)
parser.add_argument('--private-subnet-zones', type=json.loads, nargs='?',
                    required=True)
parser.add_argument('--public-subnet-cidrs', type=json.loads, nargs='?',
                    required=True)
parser.add_argument('--private-subnet-cidrs', type=json.loads, nargs='?',
                    required=True)
parser.add_argument('--nat-gateway-subnets', type=json.loads, nargs='?',
                    required=True)


args = parser.parse_args()

if not os.path.exists(args.out_path):
    os.makedirs(args.out_path)

def template(fname):
    return os.path.join(args.template_path, fname)

def outfile(fname):
    return os.path.join(args.out_path, fname)


zones = sorted(args.zones.split(','))

nat_gateway_zones = {
    args.public_subnet_zones[k] : v
    for k, v in args.nat_gateway_subnets.items()
}

subnets = {
    'public': [],
    'private': []
}
for kind in ['private', 'public']:
    cidrs = vars(args)["{}_subnet_cidrs".format(kind)]
    subnet_zones = vars(args)["{}_subnet_zones".format(kind)]

    for subnet_id, zone in sorted(subnet_zones.items(), key=lambda i: i[1]):
        subnet = {
            'id': subnet_id,
            'zone': zone,
            'cidr': cidrs[subnet_id],
            'type': 'Private' if kind == 'private' else 'Utility',
            'name': zone if kind == 'private' else 'utility-{}'.format(zone)
        }

        if kind == 'private':
            subnet['egress'] = nat_gateway_zones[zone]

        subnets[kind].append(subnet)





with open(template('cluster.yml'), 'r') as stream:
    try:
        cluster = yaml.load(stream)
    except yaml.YAMLError as exc:
        raise(exc)

    cluster['metadata'] = {'name': args.cluster_name}

    cluster['spec'].update({
        'etcdClusters': [
            {
                'name': name,
                'etcdMembers': [
                    {
                        'instanceGroup': 'master-{}'.format(zone),
                        'name': zone[-1]
                    }
                    for zone in zones
                ]
            }
            for name in ['main', 'events']
        ],
        'subnets': subnets['public'] + subnets['private'],
        'networkID': args.vpc_id,
        'configBase': "s3://{}/{}".format(args.state_bucket,
                                          args.cluster_name),
        'dnsZone': args.dns_zone,
        'networkCIDR': args.network_cidr,
        'kubernetesVersion': args.kubernetes_version,
    })

    cluster['spec']['topology'].update({
        'bastion':  {
            'bastionPublicName': 'bastion.{}'.format(args.cluster_name)
        }
    })

    with open(outfile('cluster_rendered.yml'), 'w') as out:
        yaml.dump(cluster, out, default_flow_style=False)


with open(template('bastions.yml'), 'r') as stream:
    try:
        bastions = yaml.load(stream)
    except yaml.YAMLError as exc:
        raise(exc)

    bastions['metadata'].update({
        'labels': {
            'kops.k8s.io/cluster': args.cluster_name
        }
    })

    bastions['spec'].update({
        'image': args.ami_name,
        'machineType': args.bastion_instance_type,
        'maxSize': args.bastion_count,
        'minSize': args.bastion_count,
        'subnets': [i['name'] for i in subnets['public']]
    })

    with open(outfile('bastions_rendered.yml'), 'w') as out:
        yaml.dump(bastions, out, default_flow_style=False)


with open(template('nodes.yml'), 'r') as stream:
    try:
        nodes = yaml.load(stream)
    except yaml.YAMLError as exc:
        raise(exc)

    nodes['metadata'].update({
        'labels': {
            'kops.k8s.io/cluster': args.cluster_name
        }
    })

    nodes['spec'].update({
        'image': args.ami_name,
        'machineType': args.node_instance_type,
        'maxSize': args.node_count,
        'minSize': args.node_count,
        'rootVolumeSize': args.node_volume_size,
        'subnets': [i['name'] for i in subnets['private']]
    })

    with open(outfile('nodes_rendered.yml'), 'w') as out:
        yaml.dump(nodes, out, default_flow_style=False)


masters = []
for zone in zones:
    with open(template('masters.yml'), 'r')  as stream:
        try:
            master = yaml.load(stream)
        except yaml.YAMLError as exc:
            raise(exc)

    name = 'master-{}'.format(zone)

    master['metadata'] = {
        'labels': {
            'kops.k8s.io/cluster': args.cluster_name
        },
        'name': name
    }

    master['spec'].update({
        'image': args.ami_name,
        'machineType': args.master_instance_type,
        'subnets': [i['name'] for i in subnets['private'] if i['zone'] == zone]
    })

    masters.append(master)

with open(outfile('masters_rendered.yml'), 'w') as out:
    yaml.dump_all(masters, out, default_flow_style=False,
                  explicit_start=True)
