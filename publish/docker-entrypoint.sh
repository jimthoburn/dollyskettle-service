#!/bin/sh

# Avoid “Another git process seems to be running in this repository” error
rm -f /root/git-dollyskettle.com/.git/index.lock

# Run a script, without waiting for it to finish
# https://unix.stackexchange.com/questions/86247/what-does-ampersand-mean-at-the-end-of-a-shell-script-line#answer-86253
# sh /usr/local/bin/update-content.sh &

# Hand off to the CMD
exec "$@"
