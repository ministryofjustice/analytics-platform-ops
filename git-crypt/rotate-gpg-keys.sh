#!/bin/bash
#
# For the git repo in the current directory, this script will re-initialize
# git-crypt with a new secret and re-add all the gpg keys.
#
# Purpose: by running this script, users who used to have their GPG keys in this
# git-crypt'd repo will not be able to view future changes.
#
# Notes:
# 1. Before running this you should have already removed GPG keys of old users.
# 2. Old users may still have a clone, if not the old root key to this repo,
#    giving them access the files contained up until this rotation. So those
#    secrets within the files will all need rotating as well.
# 3. It does the work in a temporary directory, pulling the changes into the
#    current directory at the end - so if the script fails half way through, the
#    current directory is left unchanged, and the script can simply be rerun.
#
# Based on https://github.com/AGWA/git-crypt/issues/47#issuecomment-212734882
#
#
set -ex

TMPDIR=`mktemp -d`
CURRENT_DIR=`git rev-parse --show-toplevel`
BASENAME=$(basename `pwd`)

# Unlock the directory - we need to copy encrypted versions of the files
git crypt unlock

# Work on copy.
cp -r `pwd` $TMPDIR

pushd $TMPDIR/$BASENAME

# Remove encrypted files and git-crypt
git crypt status | grep -v "not encrypted" > encrypted-files
awk '{print $2}' encrypted-files | xargs rm
git commit -a -m "Remove encrypted files"
rm -rf .git-crypt
git commit -a -m "Delete the .git-crypt dir, containing the user 'keys' (the repo's old root key, encrypted for each user with their public gpg key)"
rm -rf .git/git-crypt

# Create new repo root encryption key (does not encrypt files)
git crypt init

# Add existing users
for keyfilename in `ls $CURRENT_DIR/.git-crypt/keys/default/0/*gpg`; do
    basename=`basename $keyfilename`
    key=${basename%.*}

    git crypt add-gpg-user $key
done

cd $CURRENT_DIR
for i in `awk '{print $2}' ${TMPDIR}/${BASENAME}/encrypted-files`; do
    rsync -R $i $TMPDIR/$BASENAME;
done
cd $TMPDIR/$BASENAME
for i in `awk '{print $2}' encrypted-files`; do
    git add $i
done
git commit -a -m "New encrypted files"
popd

git crypt lock
git pull $TMPDIR/$BASENAME

rm -rf $TMPDIR


