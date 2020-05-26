#!/bin/bash

display_usage() {
    echo "Remove users from a git-crypt'd repo"
    echo "(Actually it removes the user's .gpg file from the repo, which contains the repo\'s"
    echo "git-crypt root encryption key, encrypted for the user with their public key."
    echo "So you still need to rotate the root key after this, as the user will still"
    echo "have the existing root key.)"
    echo
    echo "Usage: remove-gpg-users.sh <github-org> <repo-name> [filename1.gpg filename2.gpg ...]"
    echo "where:"
    echo "  <github-org> is the repo\'s github organization"
    echo "  <repo-name> is the repo\'s name"
    echo "  [filename1.gpg ...] is a space separated list of .gpg filenames to remove"
    echo "e.g.   remove-gpg-users.sh ministryofjustice analytics-platform-config 009C7ABCDEFA51899473BE4CA4B6DCF9EBAB932.gpg 2480EC66A51899473BE4CA4B6DC10A52603E7A8E.gpg"
}
# check enough arguments are supplied
if [  $# -le 3 ]
then
    echo "Error: $# is not enough arguments"
    echo
    display_usage
    exit 1
fi
if [[ ( $# == "--help") ||  $# == "-h" ]]
then
    display_usage
    exit 0
fi
GITHUB_ORG=$1
shift
GITHUB_REPO_NAME=$1
shift

set -ex

# Clone a fresh copy of the repository:
# '--mirror' gets a full copy - including all branches.
# Work on this fresh clone, just in case things fail.
CLONE_DIR=/tmp/$GITHUB_REPO_NAME.git

git clone --mirror git@github.com:$GITHUB_ORG/$GITHUB_REPO_NAME.git $CLONE_DIR

for FILENAME in "$@"; do
    
    # Delete the .gpg key file in the entire git repository, including all branches and all folders.
    # --no-blob-protection includes the latest commit in deletion too
    bfg --delete-files $FILENAME $CLONE_DIR --no-blob-protection
    
done

cd $CLONE_DIR
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push || true

# Note:
# You can ignore errors about pushing to pull requests (because you should change the root key anyway):
#       ! [remote rejected] refs/pull/99/head -> refs/pull/99/head (deny updating a hidden ref)
# BUT check you\'ve not got an error about pushing to master - you need to switch off branch protection:
#       ! [remote rejected] master -> master (protected branch hook declined)
