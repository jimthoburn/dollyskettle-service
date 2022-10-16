#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "production" ]; then

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Starting backup cron job"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Configure SSH for cron job"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  mkdir /root/.ssh

  cp /etc/secrets/id_ed25519 /root/.ssh/id_ed25519
  cp /etc/secrets/id_ed25519.pub /root/.ssh/id_ed25519.pub
  cp /etc/secrets/known_hosts /root/.ssh/known_hosts

  # https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
  sed -i -e '$a\' /root/.ssh/id_ed25519
  sed -i -e '$a\' /root/.ssh/id_ed25519.pub
  sed -i -e '$a\' /root/.ssh/known_hosts

  chmod 600 /root/.ssh/id_ed25519
  chmod 600 /root/.ssh/id_ed25519.pub
  chmod 600 /root/.ssh/known_hosts

  eval "$(ssh-agent -s)"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Run backup script in production WordPress service using SSH"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  ssh $PRODUCTION_WORDPRESS_SSH_ADDRESS "bash /usr/local/bin/backup.sh"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Start publishing service"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  
  curl -X POST -d '{}' "$PUBLISH_DEPLOY_HOOK"
  
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
  
  curl --request POST \
       --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REPLICA_API_TOKEN"
  
  curl --request POST \
       --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/resume" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REPLICA_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Finished backup cron job"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi

# if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then

#   echo "- - - - - - - - - - - - - - - - - - - - - - -"
#   echo "Stop backup status"
#   echo "- - - - - - - - - - - - - - - - - - - - - - -"

#   curl --request POST \
#        --url "https://api.render.com/v1/services/$BACKUP_STATUS_SERVICE_ID/suspend" \
#        --header 'Accept: application/json' \
#        --header "Authorization: Bearer $BACKUP_STATUS_API_TOKEN"

#   echo "- - - - - - - - - - - - - - - - - - - - - - -"
#   echo "Start remote backup"
#   echo "- - - - - - - - - - - - - - - - - - - - - - -"

#   curl -X POST -d '{}' "$REMOTE_BACKUP_DEPLOY_HOOK"

#   curl --request POST \
#        --url "https://api.render.com/v1/services/$REMOTE_BACKUP_MYSQL_SERVICE_ID/resume" \
#        --header 'Accept: application/json' \
#        --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

#   curl --request POST \
#        --url "https://api.render.com/v1/services/$REMOTE_BACKUP_WORDPRESS_SERVICE_ID/resume" \
#        --header 'Accept: application/json' \
#        --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

#   echo "- - - - - - - - - - - - - - - - - - - - - - -"
#   echo "Finished backup cron"
#   echo "- - - - - - - - - - - - - - - - - - - - - - -"

# fi
