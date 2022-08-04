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
  --result-file=/var/www/daily-wordpress-database-backup.sql \
  --databases $WORDPRESS_DB_NAME

# Make a backup with smaller files
# https://superuser.com/questions/194851/how-do-i-split-a-large-mysql-backup-file-into-multiple-files#answer-194857

rm -rf /var/www/git-wordpress/wordpress-database/
mkdir /var/www/git-wordpress/wordpress-database/

# Back up the schema
# --no-data
# Do not write any table row information (that is, do not dump table contents). This is useful if you want to dump
# only the CREATE TABLE statement for the table (for example, to create an empty copy of the table by loading the
# dump file).

mysqldump \
  -h $WORDPRESS_DB_HOST \
  -u $WORDPRESS_DB_USER \
  --password=$WORDPRESS_DB_PASSWORD \
  --single-transaction \
  --no-tablespaces \
  --no-data \
  --result-file=/var/www/git-wordpress/wordpress-database/schema.sql \
  $WORDPRESS_DB_NAME

# Back up the individual tables
# --no-create-info=TRUE
# Dump only the data. Skip writing CREATE TABLE statements.
# --extended-insert=FALSE
# Dump data in separate insert statements, so you can split the individual tables into smaller files

backup_mysql_table() {
  mysqldump \
    -h $WORDPRESS_DB_HOST \
    -u $WORDPRESS_DB_USER \
    --password=$WORDPRESS_DB_PASSWORD \
    --single-transaction \
    --no-tablespaces \
    --no-create-info=TRUE \
    --extended-insert=FALSE \
    --result-file="/var/www/git-wordpress/wordpress-database/$1.sql" \
    $WORDPRESS_DB_NAME $1
}

for tableName in \
    'wp_commentmeta' \
    'wp_comments' \
    'wp_links' \
    'wp_options' \
    'wp_postmeta' \
    'wp_posts' \
    'wp_term_relationships' \
    'wp_term_taxonomy' \
    'wp_termmeta' \
    'wp_terms' \
    'wp_usermeta'\
    'wp_users'; \
  do
    echo $tableName; \
    backup_mysql_table $tableName; \
  done

# Split `wp-posts` into smaller files with a maximum of 1000 lines each
# https://unix.stackexchange.com/questions/32626/split-a-file-by-line-and-have-control-over-resulting-files-extension
split --additional-suffix=.sql -dl 1000 /var/www/git-wordpress/wordpress-database/wp_posts.sql /var/www/git-wordpress/wordpress-database/wp_posts_
rm /var/www/git-wordpress/wordpress-database/wp_posts.sql

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
git pull --rebase --autostash origin main

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
