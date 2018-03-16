#!/usr/bin/env sh

ENVIRONMENT=""

while true; do 
	read -p "Enter the environment, i.e. dev or alpha, and press [Enter]: " environment
   	case $environment in
		[dev]*	) ENVIRONMENT=dev; break;;
		[alpha]*) ENVIRONMENT=alpha; break;;
		*	) echo "Only dev or alpha are acceptable answers"; exit;;
	esac
done

CHART="analytics-platform-helm-charts/charts/init-user"
CONFIG_FILE="analytics-platform-config/chart-env-config/${ENVIRONMENT}/init-user.yml"
USERNAME=$(helm list --max 10000 | grep 'init-user' | awk '{print $1}' | sed 's/init-user-//g')
USERNAME_FILE=$PWD/usernames.txt

stat $CHART && stat $CONFIG_FILE || exit

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

		RELEASE_NAME=init-user-$u

		JUPYTER_RELEASE_NAME=jupyter-lab-$u

		RSTUDIO_RELEASE_NAME=$u-rstudio

		INIT_RELEASE_NAME=init-user-$u

		helm del --purge $JUPYTER_RELEASE_NAME

		helm del --purge $RSTUDIO_RELEASE_NAME

		helm del --purge $INIT_RELEASE_NAME; sleep 15
			
		helm install --name=$RELEASE_NAME $CHART --set Username=$u -f $CONFIG_FILE
				
                if [[ $? -ne 0 ]]; then

			 sleep 120

			 helm install --name=$RELEASE_NAME $CHART --set Username=$u -f $CONFIG_FILE

		fi

	done <$USERNAME_FILE
    
}

redeploy

remove_username_file() {
	rm -f $USERNAME_FILE
}

trap remove_username_file EXIT HUP INT SIGINT SIGTERM QUIT PIPE TERM
