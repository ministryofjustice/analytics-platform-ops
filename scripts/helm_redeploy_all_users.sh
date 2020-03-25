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
# CONFIG_FILE="analytics-platform-config/chart-env-config/${ENVIRONMENT}/${HELM_CHART}.yml"
# USERNAME=$(helm list --max 10000 | grep "${HELM_CHART}" | awk '{print $1}' | sed "s/${HELM_CHART}-//g")
USERNAME="dhirajnarwanimoj"
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

redeploy() {

	set -x

	while IFS= read -r u; do

		RELEASE_NAME=${HELM_CHART}-$u

		JUPYTER_RELEASE_NAME=jupyter-lab-$u

		RSTUDIO_RELEASE_NAME=rstudio-$u

		# add -f $CONFIG_FILE if you want to specify a config file
		helm upgrade --install $JUPYTER_RELEASE_NAME $JUPYTER_CHART --namespace user-$u

		# add -f $CONFIG_FILE if you want to specify a config file
		helm upgrade --install $RSTUDIO_RELEASE_NAME $RSTUDIO_CHART --namespace user-$u

		# add -f $CONFIG_FILE if you want to specify a config file
		helm upgrade --install $RELEASE_NAME $CHART --set Username=$u --namespace user-$u
				
        if [[ $? -ne 0 ]]; then

			 sleep 120

			 # add -f $CONFIG_FILE if you want to specify a config file
			 helm upgrade --install $JUPYTER_RELEASE_NAME $JUPYTER_CHART --namespace user-$u

			 # add -f $CONFIG_FILE if you want to specify a config file
			 helm upgrade --install $RSTUDIO_RELEASE_NAME $RSTUDIO_CHART --namespace user-$u

			 # add -f $CONFIG_FILE if you want to specify a config file
			 helm upgrade --install $RELEASE_NAME $CHART --set Username=$u --namespace user-$u

		fi

	done <$USERNAME_FILE
    
}

redeploy

remove_username_file() {
	rm -f $USERNAME_FILE
}

trap remove_username_file EXIT HUP INT SIGINT SIGTERM QUIT PIPE TERM
