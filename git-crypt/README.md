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

1. If the person does not have a personal GPG key pair, ask them to create one - see: https://help.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key#generating-a-gpg-key

2. Ask the person to export their GPG public key like this:

       gpg --armor --export alice@cyb.org

3. Once you receive the file, save it on your disk e.g. /tmp/alice.asc

4. Import it into your GPG keyring:

       gpg --import /tmp/alice.asc

5. Tell GPG that you trust the key and sign it:

       gpg --edit-key "alice@cyb.org" trust
         # 4
         # save
         # quit
       gpg --edit-key "alice@cyb.org" sign
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

        git checkout master
        pushd .git-crypt/keys/default/0; for file in *.gpg; do echo "${file} : " && git log -- ${file} | sed -n 9p; done; popd

    Decide which users should not have access, and add their .gpg filename as a line in `keys.txt`.

 2. Make sure [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) is installed on your machine. For example:

        $ brew install bfg
        $ bfg --version
        bfg 1.13.0

 3. Make sure you're on the `master` branch. Run `remove-gpg-users.sh` to delete the keys for a list of users. This will remove the keys from all branches, folders commits.

 4. Check that the commits have been removed by running e.g:

       `git log -- .git-crypt/keys/default/0/0BC40E3E6462918D96DD1A68D5A4BCE161AC7DC8.gpg` to see the commits have been removed for old users

       `git log -- .git-crypt/keys/default/0/4F695620194C67495C8EFD2B9502AA070E5ED9A8.gpg` to see the commits are still there for current users


#### Rotate the root key

Having deleted old users in the previous section, you must now also create a fresh root key. The "root key" is the symmetric encryption key that the encrypted files in this repo are encrypted with. The script will create the .gpg files for each user, which is the root key encrypted with a user's public key.

1. Ensure you have all the current users' public GPG keys on your personal GPG keyring. If you don't you'll get an error adding them in a moment. The fingerprints of the GPG keys that you need are listed in the filenames:

       ls .git-crypt/keys/default/0/

   The keys you have on your GPG keyring are listed:

       gpg --list-keys

   To add someone, you need to ask them for their public GPG key (they are not stored in this repo) and then see the above section "Adding someone's gpg key to this repo".

2. Create a branch for this change.
3. Rotate the root key by running `rotate-gpg-keys.sh`. The script will create a temp directory in `/tmp/`, re-initialise .git-crypt with the new root key, re-encrypt the files with the new master key and refresh the user .gpg files with the new root key.
4. These changes will be commited back to the original repostory. So just run `git push` to your new branch and create a PR as normal. Every encrypted file is touched.
5. Warn other devs to reclone the repo, or you'll just get errors about git-crypt / smudge. e.g.:

       mv analytics-platform-config analytics-platform-config.bak
       git clone git@github.com:ministryofjustice/analytics-platform-config