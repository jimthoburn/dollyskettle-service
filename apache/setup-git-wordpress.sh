#!/bin/bash

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Configure Git"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git config --global user.email $GITHUB_USER_EMAIL
git config --global user.name "$GITHUB_USER_NAME"
git lfs install

cp /etc/secrets/id_ed25519 /var/www/.ssh/id_ed25519
cp /etc/secrets/id_ed25519.pub /var/www/.ssh/id_ed25519.pub
cp /etc/secrets/known_hosts /var/www/.ssh/known_hosts

# https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
sed -i -e '$a\' /var/www/.ssh/id_ed25519
sed -i -e '$a\' /var/www/.ssh/id_ed25519.pub
sed -i -e '$a\' /var/www/.ssh/known_hosts

chmod 600 /var/www/.ssh/id_ed25519
chmod 600 /var/www/.ssh/id_ed25519.pub
chmod 600 /var/www/.ssh/known_hosts

if [ "$WORDPRESS_ENVIRONMENT" = "new" ]; then

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Checkout WordPress repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"
git clone git@github.com:$GITHUB_REPOSITORY /var/www/git-wordpress

fi

# Link default HTML folder to WordPress
if [ -d "/var/www/git-wordpress/html" ]; then
  rm -df /var/www/html
  ln -s /var/www/git-wordpress/html /var/www/html
fi
