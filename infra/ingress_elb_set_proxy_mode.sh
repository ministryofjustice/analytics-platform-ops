#!/bin/sh
set -ex

PROTOCOLS=(http https)
LB_NAME=$(
    kubectl get svc nginx-ingress-controller -n kube-system -o template \
        --template="{{(index .status.loadBalancer.ingress 0).hostname}}" \
    | awk -F '-' '{print $1}'
)


aws elb create-load-balancer-policy \
    --load-balancer-name $LB_NAME \
    --policy-name ProxyPolicy \
    --policy-type-name ProxyProtocolPolicyType \
    --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true


for PROTOCOL in ${PROTOCOLS[@]}; do
    NODEPORT=$(
        kubectl get svc nginx-ingress-controller -n kube-system -o template \
        --template="
        {{- range .spec.ports -}}
            {{- if eq .name \"$PROTOCOL\" -}}
                {{- .nodePort -}}
            {{- end -}}
        {{- end -}}"
    )

    aws elb set-load-balancer-policies-for-backend-server \
        --load-balancer-name $LB_NAME \
        --instance-port $NODEPORT \
        --policy-names ProxyPolicy
done
