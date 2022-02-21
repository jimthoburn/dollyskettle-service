#!/bin/sh

if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Testing backup"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # `-L` follow redirects
  curl -L \
       --request GET \
       --url "$REMOTE_URL" \
       --header "Authorization: Basic $REMOTE_URL_AUTHORIZATION_BASIC" \
       >> backup-test-primary.html

  # `-L` follow redirects
  curl -L \
       --request GET \
       --url "$REPLICA_URL" \
       --header "Authorization: Basic $REPLICA_URL_AUTHORIZATION_BASIC" \
       >> backup-test-replica.html

  # Remove “https://”
  # https://stackoverflow.com/questions/3795512/delete-the-first-five-characters-on-any-line-of-a-text-file-in-linux-with-sed#answer-3806107
  REMOTE_HOST=$(echo $REMOTE_URL | sed 's/^........//')
  REPLICA_HOST=$(echo $REPLICA_URL | sed 's/^........//')

  sed "s/${REPLICA_HOST}/${REMOTE_HOST}/g" backup-test-replica.html >> backup-test-replica-domain-replaced.html

  DIFF_REPLICA=$(diff -u backup-test-primary.html backup-test-replica-domain-replaced.html)

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Publishing results"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  mkdir backup-test-results

  # If the files are different
  if [ ! -z "$DIFF_REPLICA" ]; then
    echo "Error: Difference found"

    echo '<html><body style="background-color: red; color: white;"><h1>Backup failed</h1></body></html>' >> backup-test-results/index.html
  else
    echo "Success: No differences found"

    echo '<html><body style="background-color: green; color: white;"><h1>Backup succeeded</h1></body></html>' >> backup-test-results/index.html
  fi

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Stopping remote backup"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REMOTE_BACKUP_WORDPRESS_SERVICE_ID/suspend" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

  curl --request POST \
       --url "https://api.render.com/v1/services/$REMOTE_BACKUP_MYSQL_SERVICE_ID/suspend" \
       --header 'Accept: application/json' \
       --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"

  # echo "- - - - - - - - - - - - - - - - - - - - - - -"
  # echo "Stopping services"
  # echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REMOTE_BACKUP_WORDPRESS_SERVICE_ID/suspend" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"
  # 
  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REMOTE_BACKUP_MYSQL_SERVICE_ID/suspend" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REMOTE_BACKUP_API_TOKEN"
  # 
  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/suspend" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REPLICA_API_TOKEN"
  # 
  # curl --request POST \
  #      --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/suspend" \
  #      --header 'Accept: application/json' \
  #      --header "Authorization: Bearer $REPLICA_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Finished testing"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
