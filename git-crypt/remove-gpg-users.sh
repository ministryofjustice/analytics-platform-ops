#!/usr/bin/env sh

set -ex

# Clone a fresh copy of the repository:
# '--mirror' gets a full copy - including all branches.
# Work on this fresh clone, just in case things fail.
git clone --mirror git@github.com:ministryofjustice/analytics-platform-config.git ../analytics-platform-config.git
KEY_FILE=$PWD/keys.txt

while IFS= read -r key; do
    
    # Delete the .gpg key in the entire git repository including all branches and all folders
    bfg --delete-files $key ../analytics-platform-config.git
    
done <$KEY_FILE 

cd ../analytics-platform-config.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push

