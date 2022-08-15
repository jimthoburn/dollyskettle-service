#!/bin/bash

# Avoid “Another git process seems to be running in this repository” error
rm -f /var/www/git-wordpress/.git/index.lock

# Link default HTML folder to WordPress
if [ -d "/var/www/git-wordpress/html" ]; then
  rm -df /var/www/html
  ln -s /var/www/git-wordpress/html /var/www/html
fi

# https://docs.docker.com/config/containers/multi-service_container/

# turn on bash's job control
set -m

# Start the primary process and put it in the background
# https://stackoverflow.com/questions/32255814/what-purpose-does-using-exec-in-docker-entrypoint-scripts-serve/32261019#32261019
exec "$@" &
  
# Start the post-deploy process
# https://unix.stackexchange.com/questions/86247/what-does-ampersand-mean-at-the-end-of-a-shell-script-line#answer-86253
bash /usr/local/bin/docker-entrypoint-environment.sh

# now we bring the primary process back into the foreground
# and leave it there
fg %1
