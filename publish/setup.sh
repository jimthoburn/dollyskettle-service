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

rm -rf /root/.ssh
mkdir /root/.ssh
cp /etc/secrets/id_ed25519 /root/.ssh/id_ed25519
cp /etc/secrets/id_ed25519.pub /root/.ssh/id_ed25519.pub
cp /etc/secrets/known_hosts /root/.ssh/known_hosts

# https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
sed -i -e '$a\' /root/.ssh/id_ed25519
sed -i -e '$a\' /root/.ssh/id_ed25519.pub
sed -i -e '$a\' /root/.ssh/known_hosts

chmod 600 /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519.pub
chmod 600 /root/.ssh/known_hosts

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Netlify Large Media"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# https://github.com/netlify/netlify-credential-helper
netlify lm:install

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Use Netlify Large Media"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Run this command to use Netlify Large Media in your current shell
source /root/.config/netlify/helper/path.bash.inc

netlify lm:info
netlify status
git config -l

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Checkout repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"
git clone --single-branch --branch automatically-cached-content git@github.com:$GITHUB_REPOSITORY /root/git-dollyskettle.com

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /root/git-dollyskettle.com"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /root/git-dollyskettle.com

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Switch to branch automatically-cached-content"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git switch automatically-cached-content

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Install dependencies"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

npm install

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
