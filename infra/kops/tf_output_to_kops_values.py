#!/usr/bin/env python3
import os
import json
import subprocess


def flatten_tf_output(d):
    '''
    Convert terraform output JSON to a flat collection of values. e.g:

    From:
    {
        "vpc_cidr": {
            "sensitive": false,
            "type": "string",
            "value": "192.168.0.0/16"
        }
    }

    To:
    {
        "vpc_cidr": "192.168.0.0/16"
    }
    '''
    return {k: v['value'] for k, v in d.items()}


def subnet_attr_lists_to_dicts(subnets):
    '''
    Transpose Terraform dict-of-lists to a list of dicts. e.g:

    From:
    {
        "availabilityZones": [
            "eu-west-1a",
            "eu-west-1b"
        ],
        "cidrs": [
            "192.168.10.0/24",
            "192.168.14.0/24"
        ],
        "ids": [
            "subnet-7d72600b",
            "subnet-7c376924"
        ]
    }

    To:
    [
        {
            "availabilityZone": "eu-west-1a",
            "cidr": "192.168.10.0/24",
            "id": "subnet-7d72600b"
        },
        {
            "availabilityZone": "eu-west-1b",
            "cidr": "192.168.14.0/24",
            "id": "subnet-7c376924"
        }
    ]
    '''
    return [
        {'availabilityZone': az, 'cidr': cidr, 'id': sid}
        for az, cidr, sid in zip(subnets['availabilityZones'],
                                 subnets['cidrs'],
                                 subnets['ids'])
    ]


# Stash current working directory
cwd = os.getcwd()

# Get path to base terraform directory
tf_root_dir = os.path.abspath(os.path.join(
    os.path.dirname(__file__),
    '../terraform'
))

# Get Terraform outputs for 'global' resources
os.chdir(os.path.join(tf_root_dir, 'global'))
tf_global = flatten_tf_output(
    json.loads(
        subprocess.getoutput("terraform output -json")))

# Get Terraform outputs for 'platform' resources
os.chdir(os.path.join(tf_root_dir, 'platform'))
tf_platform = flatten_tf_output(
    json.loads(
        subprocess.getoutput("terraform output -json")))

# Build kops values
kops_values = {
    'kopsStateBucket': tf_global['kops_bucket_name'],
    'clusterDNSName': tf_platform['dns_zone_domain'],
    'DNSZone': tf_platform['dns_zone_id'],
    'availabilityZones': tf_platform['availability_zones'],
    'OIDC': {
        'IssuerURL': tf_platform['oidc_provider_url'],
    },
    'VPC': {
        'id': tf_platform['vpc_id'],
        'cidr': tf_platform['vpc_cidr'],
        'publicSubnets': subnet_attr_lists_to_dicts(
            tf_platform['dmz_subnets']),
        'privateSubnets': subnet_attr_lists_to_dicts(
            tf_platform['private_subnets'])
    }
}

# Get current Terraform workspace name
tf_workspace = subprocess.getoutput("terraform workspace show")

# Output kops values to file
os.chdir(cwd)
with open(f'kops-tf-values.{tf_workspace}.json', 'w') as f:
    f.write(json.dumps(kops_values, sort_keys=True, indent=4))
