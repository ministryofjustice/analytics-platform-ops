#!/bin/bash
#
#
# It will re-initialize git-crypt for the repository and re-add all keys except
# the one requested for removal.
#
# Note: You still need to change all your secrets to fully protect yourself.
# Removing a user will prevent them from reading future changes but they will
# still have a copy of the data up to the point of their removal.
#
# Based on https://github.com/AGWA/git-crypt/issues/47#issuecomment-212734882
#
#
set -e

TMPDIR=`mktemp -d`
CURRENT_DIR=`git rev-parse --show-toplevel`
BASENAME=$(basename `pwd`)

# Unlock the directory, we need to copy encrypted versions of the files
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


