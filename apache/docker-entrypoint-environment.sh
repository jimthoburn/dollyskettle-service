#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then

  sh /usr/local/bin/wordpress-backup-remote.sh

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Update replica"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # https://render.com/docs/deploy-hooks
  curl -X POST -d '{}' "$REPLICA_DEPLOY_HOOK"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REPLICA_API_TOKEN"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REPLICA_API_TOKEN"

else

  if [ "$WORDPRESS_ENVIRONMENT" = "replica" ]; then
    sh /usr/local/bin/wordpress-reset.sh

    echo "- - - - - - - - - - - - - - - - - - - - - - -"
    echo "Update backup status"
    echo "- - - - - - - - - - - - - - - - - - - - - - -"

    curl -X POST -d '{}' "$BACKUP_STATUS_DEPLOY_HOOK"

    curl --request POST \
         --url "https://api.render.com/v1/services/$BACKUP_STATUS_SERVICE_ID/resume" \
         --header 'Accept: application/json' \
         --header "Authorization: Bearer $BACKUP_STATUS_API_TOKEN"
  fi

fi
