# git-crypt for Analytical Platform

Some AP repositories have git-crypt enabled. This doc describes how we add and remove users, and has associated scripts.

## Decrypting the secrets

These steps allow you to decrypt the encrypted files of a git-crypt'd repository.

1. Get your gpg key added to the repo - see [below](#adding-someones-gpg-key-to-this-repo).

2. Install git-crypt. On MacOS:

       brew install git-crypt

3. Pull the repo, so that it is the version with your newly added gpg key:

       cd analytics-platform-config  # or whatever the repo is called
       git pull

4. Decrypt the files

       git-crypt unlock

   If this fails, it might be because your gpg key requires a pass-phrase, but there is a problem with the pinentry-program. Check your gpg-agent daemon. I had to correct `~/.gnupg/gpg-agent.conf` to point to the correct `pinentry` binary, then killed the gpg-agent process and restarted it with: `gpg-agent --daemon /bin/sh`.

## Adding someone's GPG key to the repo

To enable someone to decrypt the git-crypt'd repo, we add their GPG key.

What's going on: When you "add their GPG key", it will take the repo's root key, encrypt it with the user's public GPG key and store the resulting .gpg file in this repo (in `.git-crypt/keys/default/0/`). When that user types `git-crypt unlock`, then it will decrypt that .gpg file, using their private GPG key, to get the repo's root key (storing it as `.git/git-crypt/keys/default`) and then it will use that to decrypt the repo's files.

1. If the person does not have a personal GPG key pair, ask them to create one - see: <https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key#generating-a-gpg-key>

2. Ask the person to export their GPG public key like this:

       gpg --armor --export alice@cyb.org

3. Once you receive the file, save it on your disk e.g. /tmp/alice.asc

4. Import it into your GPG keyring:

       gpg --import /tmp/alice.asc

5. Tell GPG that you trust the key and sign it:

       gpg --edit-key "alice@cyb.org" trust sign
         # 4
         # y
         # you will need to type your own passphrase
         # save

6. Confirm that '[  full  ]' is shown when you list it:

       gpg --list-keys
       pub   rsa4096 2015-02-05 [SC]
             17818CFB47FFFC384F0CC
       uid           [  full  ] alice  <alice@cyb.org>
       sub   rsa4096 2015-02-05 [E]

7. In this repo, make sure you're on a master branch, with no outstanding changes, and add the key to the .git-crypt directory:

       cd analytics-platform-config  # or whatever the repo is called
       git status
       git-crypt add-gpg-user alice@cyb.org

8. The change is already committed, so simply:

       git push

## Removing users

To remove a user's access to a git-crypt'd repo:

1. Remove the user's .gpg file
2. Rotate the root key

### Remove a user's .gpg file

You need to remove an old user's .gpg file from the repo, not just from master, but all previous commits, including branches. This prevents them from checking out this repo, getting their .gpg file, which they can decrypt to give them the repo's (symmetric) root key, which could decrypt the rest of the repo.

1. Identify the users with current access, by looking at the git history for the .gpg keys:

        pushd .git-crypt/keys/default/0; for file in *.gpg; do echo "${file} : " && git log -- ${file} | sed -n 9p; done; popd

    Decide which users should not have access, and add their .gpg filename as a line in `keys.txt`.

2. Make sure [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) is installed on your machine. For example:

        $ brew install bfg
        $ bfg --version
        bfg 1.13.0

3. Temporarily delete branch protection rules. Record what they were first! For example, the config repo has a "Branch protection rule" for master that ensures no direct pushes and requires a PR has at least 1 review. See: <https://github.com/ministryofjustice/analytics-platform-config/settings/branches>

4. Get a fresh clone the repo using the --mirror option, so that you get all the branches too. e.g.

        cd /tmp
        git clone --mirror git@github.com:ministryofjustice/analytics-platform-config

5. For each user you want to remove, you need to delete their .gpg file in this freshly cloned repo. e.g. to delete two users:

        bfg --delete-files 009C7ABCDEFA51899473BE4CA4B6DCF9EBAB93A2.gpg --no-blob-protection
        bfg --delete-files 2480EC66A51899473BE4CA4B6DC10A52603E7A8E.gpg --no-blob-protection

   This will delete the keys from all commits on all branches. We use --no-blob-protection to delete them from the current branch as well.

6. You need to 'expire' and 'prune' those deleted files from the repo, to really make them go:

        git reflog expire --expire=now --all && git gc --prune=now --aggressive

7. Now push these changes to GitHub:

        git push

   NB: You'll see some errors like:

        ! [remote rejected] refs/pull/99/head -> refs/pull/99/head (deny updating a hidden ref)

   Errors about "/pull" you can ignore - that is expected.
   HOWEVER check you've not got an error about pushing to master:

        ! [remote rejected] master -> master (protected branch hook declined)

   If you get that, you'll need to switch off branch protection and re-push.

8. Reclone and check that the commits have been removed e.g:

       cd ~/ap   # or whereever you keep your repos
       mv analytics-platform-config analytics-platform-config.bak
       git clone git@github.com:ministryofjustice/analytics-platform-config
       cd analytics-platform-config

       # check the list of current keys contain only users we want to keep
       ls .git-crypt/keys/default/0/

       # check an old user's commits are removed
       git log -- .git-crypt/keys/default/0/0BC40E3E6462918D96DD1A68D5A4BCE161AC7DC8.gpg

       # check a current user still has their commits
       git log -- .git-crypt/keys/default/0/4F695620194C67495C8EFD2B9502AA070E5ED9A8.gpg

9. Reinstate any branch protection rules on the GitHub repo.

### Rotate the root key

Having deleted old users in the previous section, you must now also create a fresh root key. The "root key" is the symmetric encryption key that the encrypted files in this repo are encrypted with. The script will create the .gpg files for each user, which is the root key encrypted with a user's public key.

1. It's easiest to make sure there are no open Pull Requests or active branches on the repository, because these can be difficult to recover once the root secret is changed. The problem is that in the repo, the files on master and the branch will be encrypted with different keys. The upshot is that it means you can't have a clone and then switch between branches, or diff between them - you simply get smudge/clean filter errors. (Although you should be able to git clone a specific branch successfully, so all is not lost if you need to recover one after the key is changed.)

   So if you can't avoid active branches, you should checkout each of these branches before you rotate the key, rebase with `git rebase origin/master` and then `git diff master >branch.diff`. This saves the branch in plain text. Once you've finished the rotation (see below), create a new branch and then `git apply branch.diff`.

2. Ensure you have all the current users' public GPG keys on your personal GPG keyring, and that they are trusted. If you don't you'll get an error adding them in a moment. The fingerprints of the GPG keys that you need are listed in the filenames:

       ls .git-crypt/keys/default/0/

   The keys you have on your GPG keyring are listed:

       gpg --list-keys |grep '^ '|sort

   To add someone, you need to ask them for their public GPG key (they are not stored in this repo) and then see the above section "Adding someone's gpg key to this repo". You will probably be able to find most people's in the Slack history.

3. Create a branch for this change:

       git checkout -b rotate-git-crypt-root-key

4. If you've not got a clone of this repo you could just download the script you need:

       wget https://raw.githubusercontent.com/ministryofjustice/analytics-platform-ops/master/git-crypt/rotate-gpg-keys.sh
       chmod +x rotate-gpg-keys.sh

5. Rotate the root key by running `rotate-gpg-keys.sh`:

       ~/ap/analytics-platform-ops/git-crypt/rotate-gpg-keys.sh

   For the git repo in the current directory, this script will re-initialize git-crypt with a new secret and re-add all the gpg keys. It does the work in a temporary directory, pulling the changes into the current directory at the end - so if the script fails half way through, the current directory is left unchanged, and the script can simply be rerun.

6. Push the changes to the remote:

       git push -u origin rotate-git-crypt-root-key

7. Create a PR as normal, with suggested comment:

       Rotated the git crypt root key by following the standard process: https://github.com/ministryofjustice/analytics-platform-ops/tree/master/git-crypt#rotate-the-root-key

       To test it works:

           git clone git@github.com:ministryofjustice/analytics-platform-config /tmp/myrepo
           git checkout rotate-git-crypt-root-key
           cd /tmp/myrepo
           git crypt unlock

       Once this is merged, all users will need to reclone, to avoid git-crypt error messages on push/pull:

           mv analytics-platform-config analytics-platform-config.bak
           git clone git@github.com:ministryofjustice/analytics-platform-config
           git crypt unlock

   In this PR, every encrypted file is touched.

8. Just check you can still unlock it using your GPG key:

       git clone git@github.com:ministryofjustice/analytics-platform-config /tmp/myrepo
       cd /tmp/myrepo
       git crypt unlock

9. When merged, warn other devs to reclone the repo, or they'll just get errors about git-crypt / smudge. e.g.:

       mv analytics-platform-config analytics-platform-config.bak
       git clone git@github.com:ministryofjustice/analytics-platform-config
       git crypt unlock
