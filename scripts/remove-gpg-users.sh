#!/usr/bin/env sh

set -ex

# Specify git repo to remove users that have left AP
GIT_REPO=analytics-platform-data-engineering-ops

# Clone a fresh copy of the repository:
# '--mirror' gets a full copy - including all branches.
# Work on this fresh clone, just in case things fail.
git clone --mirror git@github.com:ministryofjustice/$GIT_REPO.git ../$GIT_REPO.git
KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    # Delete the .gpg key in the entire git repository including all branches and all folders
    bfg --delete-files $key ../$GIT_REPO.git
    
done <$KEY_FILE 

cd ../$GIT_REPO.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push

