#!/bin/sh

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting setup"
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
echo "Checkout repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"
git clone git@github.com:$GITHUB_REPOSITORY /var/www/git-wordpress

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Import MySQL database"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Combine data for `wp_posts` table into a single file
cat /var/www/git-wordpress/wordpress-database/wp_posts_1.sql > /var/www/git-wordpress/wordpress-database/wp_posts.sql
cat /var/www/git-wordpress/wordpress-database/wp_posts_2.sql >> /var/www/git-wordpress/wordpress-database/wp_posts.sql

# Import the schema
mysql \
  -h $WORDPRESS_DB_HOST \
  -u $WORDPRESS_DB_USER \
  --password=$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME \
  < /var/www/git-wordpress/wordpress-database/schema.sql

# Import the tables
import_mysql_table() {
  mysql \
    -h $WORDPRESS_DB_HOST \
    -u $WORDPRESS_DB_USER \
    --password=$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME \
    < "/var/www/git-wordpress/wordpress-database/$1.sql"
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
    import_mysql_table $tableName; \
  done

# Remove temporary file
rm /var/www/git-wordpress/wordpress-database/wp_posts.sql

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Replace default HTML folder"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

rm -df /var/www/html
ln -s /var/www/git-wordpress/html /var/www/html

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
