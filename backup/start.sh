#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Stop backup status"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  curl --request POST \
       --url "https://api.render.com/v1/services/$BACKUP_STATUS_SERVICE_ID/suspend" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $BACKUP_STATUS_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Start remote backup"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  curl -X POST -d '{}' "$REMOTE_BACKUP_DEPLOY_HOOK"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REMOTE_BACKUP_MYSQL_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REMOTE_BACKUP_WORDPRESS_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Finished backup cron"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
