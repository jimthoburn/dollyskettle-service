#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "new" ]; then

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

bash /usr/local/bin/setup-git-wordpress.sh

bash /usr/local/bin/setup-mysql.sh

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished setup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
