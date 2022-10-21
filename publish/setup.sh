#!/bin/bash

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /root"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /root

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Configure Git"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git config --global user.email $GITHUB_USER_EMAIL
git config --global user.name "$GITHUB_USER_NAME"
git lfs install

# https://github.com/netlify/netlify-credential-helper
netlify lm:install

rm -rf /root/.ssh
mkdir /root/.ssh

cp /etc/secrets/id_ed25519 /root/.ssh/id_ed25519
cp /etc/secrets/id_ed25519.pub /root/.ssh/id_ed25519.pub
cp /etc/secrets/known_hosts /root/.ssh/known_hosts

# Work around for `netlify-credential-helper`
# https://github.com/netlify/netlify-credential-helper/issues/41#issuecomment-905195175
# https://docs.netlify.com/cli/get-started/#config-json-location
cp /etc/secrets/config.json /root/.config/netlify/config.json

# https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
sed -i -e '$a\' /root/.ssh/id_ed25519
sed -i -e '$a\' /root/.ssh/id_ed25519.pub
sed -i -e '$a\' /root/.ssh/known_hosts
sed -i -e '$a\' /root/.config/netlify/config.json

chmod 600 /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519.pub
chmod 600 /root/.ssh/known_hosts
chmod 600 /root/.config/netlify/config.json

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Use Netlify Large Media"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Run this command to use Netlify Large Media in your current shell
# bash /root/.config/netlify/helper/path.bash.inc

PATH="/root/.config/netlify/helper/bin":$PATH

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Show Netlify and Git status"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

netlify
netlify lm:info
netlify status
git config -l

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Checkout repository for published site"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"

# https://stackoverflow.com/questions/42019529/how-to-clone-pull-a-git-repository-ignoring-lfs
GIT_LFS_SKIP_SMUDGE=1 \
  git clone \
    git@github.com:$GITHUB_REPOSITORY \
    /root/git-dollyskettle.com

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /root/git-dollyskettle.com"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /root/git-dollyskettle.com

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check git status"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git status

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Switch to branch main"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git switch main

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Install dependencies"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

npm install

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check git status"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git status

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Get LFS files"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# https://github.com/git-lfs/git-lfs/issues/325

# Fetch a few times, in case the initial fetch is incomplete
git lfs fetch
git lfs fetch
git lfs fetch

git lfs pull

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check git status"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git status

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check disk size"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

df -h

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Checkout repository for WordPress"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git clone git@github.com:$GITHUB_REPOSITORY_WORDPRESS /root/git-wordpress

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check disk size"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

df -h

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
