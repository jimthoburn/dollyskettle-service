#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "new" ]; then

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Import MySQL database"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Combine data for `wp_posts` table into a single file
# https://unix.stackexchange.com/questions/24630/whats-the-best-way-to-join-files-again-after-splitting-them
cat /var/www/git-wordpress/wordpress-database/wp_posts_*.sql > /var/www/git-wordpress/wordpress-database/wp_posts.sql

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
echo "Finished setting up MySQL"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
