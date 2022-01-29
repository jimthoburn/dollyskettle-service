#!/bin/sh

# Run remote backup, without waiting for it to finish
# https://unix.stackexchange.com/questions/86247/what-does-ampersand-mean-at-the-end-of-a-shell-script-line#answer-86253
sh /usr/local/bin/wordpress-backup-remote.sh &

# Hand off to the CMD
exec "$@"
