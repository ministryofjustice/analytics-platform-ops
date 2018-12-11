#!/usr/bin/env python3
import os
import json
import subprocess
import argparse


CWD = os.path.abspath(os.path.dirname(__file__))
TF_BASE_DIR = os.path.abspath(os.path.join(
    CWD, '../terraform'
))


def flatten_tf_output(d):
    """Convert terraform output JSON to a flat dict

    >>> flatten_tf_output({
    ...    'vpc_cidr': {
    ...        'sensitive': False,
    ...        'type': 'string',
    ...        'value': '192.168.0.0/16'
    ...    }
    ... })
    {'vpc_cidr': '192.168.0.0/16'}
    """
    return {k: v['value'] for k, v in d.items()}


def subnet_attr_lists_to_dicts(subnets):
    """Transpose Terraform dict of lists to a list of dicts. e.g:

    >>> subnet_attr_lists_to_dicts({
    ...     'availabilityZones': [
    ...         'eu-west-1a',
    ...         'eu-west-1b'
    ...     ],
    ...     'cidrs': [
    ...         '192.168.10.0/24',
    ...         '192.168.14.0/24'
    ...     ],
    ...     'ids': [
    ...         'subnet-7d72600b',
    ...         'subnet-7c376924'
    ...     ]
    ... })
    [{'availabilityZone': 'eu-west-1a', 'cidr': '192.168.10.0/24', 'id': \
'subnet-7d72600b'}, {'availabilityZone': 'eu-west-1b', 'cidr': \
'192.168.14.0/24', 'id': 'subnet-7c376924'}]
    """
    return [
        {'availabilityZone': az, 'cidr': cidr, 'id': sid}
        for az, cidr, sid in zip(subnets['availabilityZones'],
                                 subnets['cidrs'],
                                 subnets['ids'])
    ]


def get_tf_resource_dir(tf_resources):
    return os.path.abspath(os.path.join(TF_BASE_DIR, tf_resources))


def get_tf_output(tf_resources):
    os.chdir(get_tf_resource_dir(tf_resources))
    exitcode, output = subprocess.getstatusoutput("terraform output -json")
    assert exitcode == 0, output
    return flatten_tf_output(json.loads(output))


def get_terraform_workspace():
    os.chdir(get_tf_resource_dir('platform-base'))
    return subprocess.getoutput("terraform workspace show")


def build_kops_values(global_resources, platform_resources):
    """Build data dict for use by Kops template
    """
    return {
        'kopsStateBucket': global_resources['kops_bucket_name'],
        'clusterDNSName': platform_resources['dns_zone_domain'],
        'DNSZone': platform_resources['dns_zone_id'],
        'availabilityZones': platform_resources['availability_zones'],
        'OIDC': {
            'IssuerURL': platform_resources['oidc_provider_url'],
            'ClientID': platform_resources['oidc_client_id'],
        },
        'VPC': {
            'id': platform_resources['vpc_id'],
            'cidr': platform_resources['vpc_cidr'],
            'publicSubnets': subnet_attr_lists_to_dicts(
                platform_resources['dmz_subnets']),
            'privateSubnets': subnet_attr_lists_to_dicts(
                platform_resources['private_subnets'])
        },
        'extraSecurityGroups': {
            'masters': platform_resources['extra_master_sg_id'],
            'nodes': platform_resources['extra_node_sg_id'],
            'bastions': platform_resources['extra_bastion_sg_id'],
        }
    }


# Create command line args
parser = argparse.ArgumentParser(description='Generate kops values JSON file')
parser.add_argument('--workspace', default=get_terraform_workspace(),
                    help=('Terraform workspace name ' +
                          '(default: current workspace)'))
parser.add_argument('--test', action='store_true', help='Run tests')
args = parser.parse_args()


if __name__ == "__main__":
    if args.test:
        import doctest
        doctest.testmod(verbose=True)
    else:
        # Build kops values dict
        print(f'Building kops values for {args.workspace} workspace')
        kops_values = build_kops_values(
            get_tf_output('global'), get_tf_output('platform-base'))

        # Output kops values to file
        out = f'{CWD}/kops-tf-values.{args.workspace}.json'
        with open(out, 'w') as f:
            f.write(json.dumps(kops_values, sort_keys=True, indent=4))
            print(f'Kops values written to {out}')
