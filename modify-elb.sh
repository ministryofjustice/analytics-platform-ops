#!/bin/sh

aws elb describe-load-balancer-policy-types

aws elb create-load-balancer-policy \
    --load-balancer-name ab39ea68bcb8f11e6a3ae02be73b9125 \
    --policy-name k8s-proxy-policy \
    --policy-type-name ProxyProtocolPolicyType \
    --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true

aws elb set-load-balancer-policies-for-backend-server \
    --load-balancer-name ab39ea68bcb8f11e6a3ae02be73b9125 \
    --instance-port 31911 \
    --policy-names k8s-proxy-policy

aws elb set-load-balancer-policies-for-backend-server \
    --load-balancer-name ab39ea68bcb8f11e6a3ae02be73b9125 \
    --instance-port 32148 \
    --policy-names k8s-proxy-policy
