#!/bin/bash

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting backup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /var/www"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /var/www

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Configure Git"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git config --global user.email $GITHUB_USER_EMAIL
git config --global user.name "$GITHUB_USER_NAME"
git lfs install

rm -rf /var/www/.ssh
mkdir /var/www/.ssh
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

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Put site in maintenance mode"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "<?php \$upgrading = time(); ?>" > /var/www/git-wordpress/html/.maintenance

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Create a backup of MySQL database"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

mysqldump \
  -h $WORDPRESS_DB_HOST \
  -u $WORDPRESS_DB_USER \
  --password=$WORDPRESS_DB_PASSWORD \
  --single-transaction --no-tablespaces \
  --result-file=/var/www/git-wordpress/wordpress-database.sql \
  --databases $WORDPRESS_DB_NAME

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /var/www/git-wordpress"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /var/www/git-wordpress

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check changed files into the repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"
git add .
git commit -m "Automatic commit with the latest content"
git pull --rebase

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Put site back in non-maintenance mode"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

rm /var/www/git-wordpress/html/.maintenance

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Push commits to remote repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git push origin

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished backing up"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
