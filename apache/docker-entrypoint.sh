#!/bin/sh

# Avoid “Another git process seems to be running in this repository” error
rm -f /var/www/git-wordpress/.git/index.lock

# Hand off to the CMD
exec "$@"
