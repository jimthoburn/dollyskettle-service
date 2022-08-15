#!/bin/bash

# Avoid “Another git process seems to be running in this repository” error
rm -f /var/www/git-wordpress/.git/index.lock

# Link default HTML folder to WordPress
if [ -d "/var/www/git-wordpress/html" ]; then
  rm -df /var/www/html
  ln -s /var/www/git-wordpress/html /var/www/html
fi

# Run a script, without waiting for it to finish
# https://unix.stackexchange.com/questions/86247/what-does-ampersand-mean-at-the-end-of-a-shell-script-line#answer-86253
bash /usr/local/bin/docker-entrypoint-environment.sh &

# Hand off to the CMD
exec "$@"
