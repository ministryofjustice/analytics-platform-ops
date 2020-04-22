#!/usr/bin/env sh

ENVIRONMENT=""

HELM_CHART="config-user"

while true; do 
	read -p "Enter the environment, i.e. dev or alpha, and press [Enter]: " environment
   	case $environment in
		[dev]*	) ENVIRONMENT=dev; break;;
		[alpha]*) ENVIRONMENT=alpha; break;;
		*	) echo "Only dev or alpha are acceptable answers"; exit;;
	esac
done

CHART="../../analytics-platform-helm-charts/charts/${HELM_CHART}"
RSTUDIO_CHART="../../analytics-platform-helm-charts/charts/rstudio"
JUPYTER_CHART="../../analytics-platform-helm-charts/charts/jupyter-lab"
RSTUDIO_CONFIG_FILE="../../analytics-platform-config/chart-env-config/${ENVIRONMENT}/rstudio.yml"
JUPYTER_CONFIG_FILE="../../analytics-platform-config/chart-env-config/${ENVIRONMENT}/jupyter.yml"
# USERNAME=$(helm list --max 10000 | grep "${HELM_CHART}" | awk '{print $1}' | sed "s/${HELM_CHART}-//g")

USERNAME_FILE=$PWD/usernames.txt

stat $CHART || exit

declare -a USERNAMES=$USERNAME

username_file() {
	for i in $USERNAMES; do 
		echo ${i[@]} >> $USERNAME_FILE
		shift
	done
}

username_file

# while IFS= read -r u; do
# 	u=$(echo "$u" | tr '[:upper:]' '[:lower:]')
# 	helm delete --purge $u-rstudio

# done <$USERNAME_FILE 


redeploy() {
	set -x

	while IFS= read -r u; do
		u=$(echo "$u" | tr '[:upper:]' '[:lower:]')

		RELEASE_NAME=$HELM_CHART-$u
		JUPYTER_RELEASE_NAME=jupyter-lab-$u
		RSTUDIO_RELEASE_NAME=rstudio-$u

		helm upgrade --install $JUPYTER_RELEASE_NAME $JUPYTER_CHART --recreate-pods --set Username=$u --set aws.iamRole=${ENVIRONMENT}_user_$u -f $JUPYTER_CONFIG_FILE --namespace user-$u
		helm upgrade --install $RSTUDIO_RELEASE_NAME $RSTUDIO_CHART --force --recreate-pods --set username=$u --set aws.iamRole=${ENVIRONMENT}_user_$u -f $RSTUDIO_CONFIG_FILE --namespace user-$u
		helm upgrade --install $RELEASE_NAME $CHART --set Username=$u --recreate-pods --namespace user-$u

		# If the above helm upgrade fails due to Timeout/TLS handshake issues then retry the upgrade
		if [[ $? -ne 0 ]]; then
			helm upgrade --install $JUPYTER_RELEASE_NAME $JUPYTER_CHART --recreate-pods --set Username=$u --set aws.iamRole=${ENVIRONMENT}_user_$u -f $JUPYTER_CONFIG_FILE --namespace user-$u
			helm upgrade --install $RSTUDIO_RELEASE_NAME $RSTUDIO_CHART --force --recreate-pods --set username=$u --set aws.iamRole=${ENVIRONMENT}_user_$u -f $RSTUDIO_CONFIG_FILE --namespace user-$u
			helm upgrade --install $RELEASE_NAME $CHART --recreate-pods --set Username=$u --namespace user-$u
		fi
	done <$USERNAME_FILE 
}

redeploy

remove_username_file() {
	rm -f $USERNAME_FILE
}

trap remove_username_file EXIT HUP INT SIGINT SIGTERM QUIT PIPE TERM
