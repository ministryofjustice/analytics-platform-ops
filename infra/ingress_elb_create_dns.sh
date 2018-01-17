#!/bin/sh
set -ex

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Arguments: DOMAIN"
  exit 2
fi

DOMAIN=$1
WILDCARD_DOMAINS=(tools apps services)


HOSTED_ZONE_ID=$(
    aws route53 list-hosted-zones \
        --query "HostedZones[?Name=='${DOMAIN}.'].Id" \
    | jq -r '.[0]'
)

ELB_HOSTNAME=$(
    kubectl get svc cluster-ingress-nginx-ingress-controller -o template \
        --template="{{(index .status.loadBalancer.ingress 0).hostname}}"
)

ELB_NAME=$(echo $ELB_HOSTNAME | awk -F '-' '{print $1}')

ELB_HOSTED_ZONE_ID=$(
    aws elb describe-load-balancers --load-balancer-names $ELB_NAME \
    | jq -r '.["LoadBalancerDescriptions"][0]["CanonicalHostedZoneNameID"]'
)


for SUBDOMAIN in ${WILDCARD_DOMAINS[@]}; do
    cat << EOF > /tmp/elb_dns.json
        {
            "Comment": "Wildcard domain for $SUBDOMAIN",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "*.$SUBDOMAIN.$DOMAIN.",
                        "Type": "A",
                        "AliasTarget": {
                            "DNSName": "dualstack.$ELB_HOSTNAME.",
                            "HostedZoneId": "$ELB_HOSTED_ZONE_ID",
                            "EvaluateTargetHealth": false
                        }
                    }
                }
            ]
        }
EOF

    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch file:///tmp/elb_dns.json
done
