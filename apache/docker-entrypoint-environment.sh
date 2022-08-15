#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "production" ]; then

  bash /usr/local/bin/backup.sh

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Start publishing service"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # curl -X POST -d '{}' "$PUBLISH_DEPLOY_HOOK"

  curl --request POST \
    --url "https://api.render.com/v1/services/$PUBLISH_SERVICE_ID/resume" \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $PUBLISH_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Deploy replica"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # https://render.com/docs/deploy-hooks
  curl -X POST -d '{}' "$REPLICA_MYSQL_DEPLOY_HOOK"
  curl -X POST -d '{}' "$REPLICA_WORDPRESS_DEPLOY_HOOK"

  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/resume" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REPLICA_API_TOKEN"

  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/resume" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REPLICA_API_TOKEN"
fi

# if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then
  
#   bash /usr/local/bin/reset.sh
#   bash /usr/local/bin/wordpress-backup-remote.sh

#   echo "- - - - - - - - - - - - - - - - - - - - - - -"
#   echo "Update replica"
#   echo "- - - - - - - - - - - - - - - - - - - - - - -"

#   # https://render.com/docs/deploy-hooks
#   curl -X POST -d '{}' "$REPLICA_MYSQL_DEPLOY_HOOK"
#   curl -X POST -d '{}' "$REPLICA_WORDPRESS_DEPLOY_HOOK"

#   curl --request POST \
#        --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/resume" \
#        --header 'Accept: application/json' \
#        --header "Authorization: Bearer $REPLICA_API_TOKEN"

#   curl --request POST \
#        --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/resume" \
#        --header 'Accept: application/json' \
#        --header "Authorization: Bearer $REPLICA_API_TOKEN"

# fi

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
