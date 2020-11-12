#! /bin/bash


NAMESPACE=apps-prod
CONTAINER=fluent-bit
OLD_IMAGE=fluent/fluent-bit:1.1.1
NEW_IMAGE=593291632749.dkr.ecr.eu-west-1.amazonaws.com/fluent-bit:1.1.1


function uses_old_image() {
    local deployment=${1:?}

    kubectl -n ${NAMESPACE} get deployment "${deployment}" -o yaml | grep -q "image: ${OLD_IMAGE}"
}

## NOTE: You can also replace the following with a newline-separated list of
##       `Deployments` to update, e.g.
#
# DEPLOYMENTS="
# deployment-to-update-1
# deployment-to-update-2
# deployment-to-update-3
# "
DEPLOYMENTS=$(kubectl -n ${NAMESPACE} get deployment | grep \\-webapp | cut -d" " -f1)

for deployment in $DEPLOYMENTS; do
    echo
    echo "Processing '${deployment}'..."

    if uses_old_image "${deployment}"; then
        kubectl -n "${NAMESPACE}" set image "deployment/${deployment}" ${CONTAINER}=${NEW_IMAGE}
        echo "Image replaced."
    else
        echo "Image NOT replaced (fluent-bit not used or already using new image)"
    fi
done
