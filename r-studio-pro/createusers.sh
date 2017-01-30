#!/bin/bash
set -ex

GROUP=rstudio

while read USER; do
  USER=$(echo $USER |
    tr '[:upper:]' '[:lower:]' |
    sed 's/.gov.uk$//g' |
    sed 's/[^a-z0-9_]/-/g' |
    cut -c1-32)

  if ! getent passwd $USER > /dev/null 2>&1; then
    sudo useradd -g $GROUP -m -d /home/$USER -s /dev/null $USER
  fi
done <$1
