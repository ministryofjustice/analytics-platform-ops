#!/usr/bin/env bash

set -uo pipefail

APP=
DEBUG=false
DRY_RUN=true
CONFIG_PATH=
HELM_VER=2.9.1
MOJANALYTICS_REPO=http://moj-analytics-helm-repo.s3-website-eu-west-1.amazonaws.com
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
SAVE_VALUES=false

usage() {
  cat << EOF

  Usage:

  REQUIRED
  -a - The Name of the application/helm chart you want to upgrade

  [Optional]
  -d - Debug: true or false, Default: false
  -f - File: Path to config/values file, i.e. analytics-platform-config/chart-env-config/<ENV>/rstudio.yml
  -s - Save release values yaml files: true or false, Default: false
  -h - Print usage

  Example: Upgrade all rstudio releases in dev with debug on and save the resulting values yaml file(s)

    upgrade_tools_releases.sh -a rstudio -f analytics-platform-config/chart-env-config/dev/rstudio.yml -s true -d true

EOF
}

while getopts a:d:f:s:h option; do
  case $option in
    a   ) APP="$OPTARG";;
    d   ) DEBUG="$OPTARG";;
    f   ) CONFIG_PATH="$OPTARG";;
    s   ) SAVE_VALUES="$OPTARG";;
    h   ) usage; exit 0;;
    \?  ) usage; exit 1;;
  esac
done

# Exit if $APP has not been set
if [ -z $APP ]; then
  usage; exit 1
fi

# Determine the helm chart from the argument to the -a flag
HELM_REPO=mojanalytics/$APP

# If CONFIG_PATH has a value prefix it with "--values"
if [[ -n $CONFIG_PATH && -f $CONFIG_PATH ]]; then

  CONFIG_PATH="--values ${CONFIG_PATH}"

elif [[ -n $CONFIG_PATH && ! -f $CONFIG_PATH ]]; then

  Printf "\nCannot find config file: ${CONFIG_PATH}\n\nAre you sure it exists or is a file?\n\n"
  exit 1

fi

while true; do
	read -p "Is this a DRY RUN? i.e. NO-OP [y/N]: " dry_run
	case $dry_run in
	    [y]*    ) DRY_RUN=true; DEBUG=true; break;;
	    [N]*    ) DRY_RUN=false; break;;
	    *       ) echo "Answer y to simulate the operation.  Answer N to perform the operation."; exit;;
    esac
done

grab_helm() {
  wget --progress=dot:giga -O helm https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VER-$PLATFORM-amd64.tar.gz

  if [ -f helm ]; then
    PATH="$PATH:$(pwd)"
    chmod +x helm
  fi
}

# Grab the Helm client if not installed
which helm || grab_helm

# Ensure we've added our helm repo
helm repo add mojanalytics $MOJANALYTICS_REPO && helm repo update

# Get a list of usernames
USERNAMES=$(helm ls ${APP} --max 10000 | awk '{print $10}' | sed 's/user-//g')

for user in $USERNAMES; do

  RELEASE_NAME=$user-$APP

# We get the values from current release in order to reuse them. See: https://github.com/kubernetes/helm/issues/3957#issuecomment-384685681
  helm get values $RELEASE_NAME > ${user}.yaml \
  && helm upgrade --recreate-pods --dry-run=$DRY_RUN --namespace=user-$user $RELEASE_NAME $HELM_REPO \
    --debug=$DEBUG --values ${user}.yaml $CONFIG_PATH

  if [ $SAVE_VALUES == false ]; then
    rm -f ${user}.yaml
  fi

done
