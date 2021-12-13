#!/bin/sh

curl -X POST -d '{}' "$REMOTE_BACKUP_HOOK_HOST/cgi-bin/$REMOTE_BACKUP_HOOK_ID.sh"
