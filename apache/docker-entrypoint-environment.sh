#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "replica" ]; then
  bash /usr/local/bin/reset.sh

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Update backup status"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  curl -X POST -d '{}' "$BACKUP_STATUS_DEPLOY_HOOK"

  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$BACKUP_STATUS_SERVICE_ID/resume" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $BACKUP_STATUS_API_TOKEN"
fi
