#!/bin/bash

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting publishing"
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
echo "Get latest images from WordPress backup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /root/git-wordpress

eval "$(ssh-agent -s)"

git reset --hard
git clean -fdx
git pull --rebase --autostash

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Copy WordPress backup images for publishing"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cp --recursive /root/git-wordpress/html/wp-content/uploads/* /root/git-dollyskettle.com/_pictures

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /root/git-dollyskettle.com"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /root/git-dollyskettle.com

# echo "- - - - - - - - - - - - - - - - - - - - - - -"
# echo "Switch to branch automatically-cached-content"
# echo "- - - - - - - - - - - - - - - - - - - - - - -"

# git switch automatically-cached-content

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Install dependencies"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

npm install

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Download the latest API data and images"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

npm run download:images

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check changed files into the repository (only _api and _pictures)"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"

git add _api
git add _pictures

git commit -m "Update “_api” and “_pictures” with the latest content"

# https://stackoverflow.com/questions/3636914/how-can-i-see-what-i-am-about-to-push-with-git
DIFF_ORIGIN=$(git diff --stat --cached origin/automatically-cached-content)

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "diff"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo $DIFF_ORIGIN

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Push commits to remote repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# https://nicolas.busseneau.fr/en/blog/2020/12/two-step-push-accelerating-git-lfs-migration-for-big-repositories
#   Push pointer files only
#     GIT_LFS_SKIP_PUSH=1 git push --no-verify origin automatically-cached-content
#   Push LFS objects
#     git lfs push origin automatically-cached-content
#     git lfs push --all origin automatically-cached-content

git pull --rebase
git push origin automatically-cached-content

# SHIM: Work around “context deadline exceeded” error in Netlify
#       that seems to cause a build to fail the first time it’s tried
#       after a push to origin with new images
# If there’s anything to push
# https://linuxacademy.com/blog/linux/conditions-in-bash-scripting-if-statements/
if [ ! -z "$DIFF_ORIGIN" ]; then
  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "retry deploy"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  # https://app.netlify.com/sites/dollyskettle-com/settings/deploys
  #
  # Trigger a deploy from “automatically-cached-content” branch:
  curl -X POST -d {} https://api.netlify.com/build_hooks/6010c36f101bb451222add75
  #
  # Trigger a deploy from “main” branch:
  # curl -X POST -d {} https://api.netlify.com/build_hooks/6010c33d7a05f66e370cd53f
else
  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "nothing to push"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"
fi

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished publishing"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Stop publishing service"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# curl --request POST \
#      --url "https://api.render.com/v1/services/$PUBLISH_SERVICE_ID/suspend" \
#      --header 'Accept: application/json' \
#      --header "Authorization: Bearer $PUBLISH_API_TOKEN"

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished stopping publishing service"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
