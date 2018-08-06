#!/bin/bash

if [ $# -lt 1 ]; then
  echo 1>&2 "$0: Arguments: ENVIRONMENT"
  exit 2
fi

env=$1
cwd=$(pwd)

cd ../environments/$env
IFS=
resources=$( \
    terraform show -no-color \
    | grep -A1 "^module" \
    | grep -v '^--' \
    | sed -e 's/^  id = //g' \
    | sed -Ee 's/\.([0-9]+):/[\1]/g' \
    | sed -e 's/:$//g' \
    | awk 'NR%2{printf "%s ",$0;next;}1' \
    | grep -v '\.data\.' \
)

cd $cwd
workspace=$(terraform workspace show)
IFS=' '

echo $resources | while read -r resource; do
    read -r -a parts <<< "$resource"
    terraform import -var-file=vars/$workspace.tfvars ${parts[0]} ${parts[1]}
done
