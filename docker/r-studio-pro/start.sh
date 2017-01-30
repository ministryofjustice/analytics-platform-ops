#!/bin/bash
set -ex

GROUP=staff
USER_UID=1001

# If we have a k8s user namespace, strip prefix and that's our username
# Otherwise use passed-in username, or default
# if [ $USER_NAMESPACE ]
# then
#     USER=$(echo $USER_NAMESPACE | sed 's/^user-//')
# else
#     USER=${1:=rstudio}
# fi

# while read USER; do
#   USER=$(echo $USER |
#     tr '[:upper:]' '[:lower:]' |
#     sed 's/.gov.uk$//g' |
#     sed 's/[^a-z0-9_]/-/g' |
#     cut -c1-32)

#   if ! getent passwd $USER > /dev/null 2>&1; then
#     sudo useradd -g $GROUP -m -d /mnt/$USER -s /dev/null $USER
#   fi
# done <$1

  # && useradd rstudio \
  # && echo "rstudio:rstudio" | chpasswd \
  #   && mkdir /home/rstudio \
  #   && chown rstudio:rstudio /home/rstudio \
  #   && addgroup rstudio staff \
useradd -g $GROUP -u $USER_UID -d /home/$USER $USER

echo "auth-proxy-sign-in-url=https://${USER}.r-studio.users.analytics.kops.integration.dsd.io/login" >> /etc/rstudio/rserver.conf
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0
