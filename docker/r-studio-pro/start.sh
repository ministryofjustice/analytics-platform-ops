#!/bin/bash
set -ex

GROUP=staff
USER_UID=1001

useradd -g $GROUP -u $USER_UID -d /home/$USER $USER

echo "auth-proxy-sign-in-url=https://${USER}.rstudio.users.analytics.kops.integration.dsd.io/login" >> /etc/rstudio/rserver.conf
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> /usr/local/lib/R/etc/Renviron
echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /usr/local/lib/R/etc/Renviron

/usr/lib/rstudio-server/bin/rserver --server-daemonize 0
