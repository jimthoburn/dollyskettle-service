#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "production" ]; then

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Testing backup"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # `-L` follow redirects
  curl -L \
       --request GET \
       --url "$PRODUCTION_URL" \
       --header "Authorization: Basic $PRODUCTION_URL_AUTHORIZATION_BASIC" \
       >> backup-test-primary.html

  # `-L` follow redirects
  curl -L \
       --request GET \
       --url "$REPLICA_URL" \
       --header "Authorization: Basic $REPLICA_URL_AUTHORIZATION_BASIC" \
       >> backup-test-replica.html

  # Remove “https://”
  # https://stackoverflow.com/questions/3795512/delete-the-first-five-characters-on-any-line-of-a-text-file-in-linux-with-sed#answer-3806107
  PRODUCTION_HOST=$(echo $PRODUCTION_URL | sed 's/^........//')
  REPLICA_HOST=$(echo $REPLICA_URL | sed 's/^........//')

  sed "s/${REPLICA_HOST}/${PRODUCTION_HOST}/g" backup-test-replica.html >> backup-test-replica-domain-replaced.html

  DIFF_REPLICA=$(diff -u backup-test-primary.html backup-test-replica-domain-replaced.html)

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Publishing results"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  mkdir backup-test-results
 
  # If the files are different
  if [ ! -z "$DIFF_REPLICA" ]; then
    echo "Error: Difference found"
    echo "$DIFF_REPLICA"

    echo '<html><body style="background-color: red; color: white;"><h1>Backup failed</h1><ul><li><a href="backup-test-primary.html">backup-test-primary.html</a></li><li><a href="backup-test-replica-domain-replaced.html">backup-test-replica-domain-replaced.html</a></li></ul></body></html>' >> backup-test-results/index.html
  else
    echo "Success: No differences found"

    echo '<html><body style="background-color: green; color: white;"><h1>Backup succeeded</h1><ul><li><a href="backup-test-primary.html">backup-test-primary.html</a></li><li><a href="backup-test-replica-domain-replaced.html">backup-test-replica-domain-replaced.html</a></li></ul></body></html>' >> backup-test-results/index.html

    echo "- - - - - - - - - - - - - - - - - - - - - - -"
    echo "Stopping replica"
    echo "- - - - - - - - - - - - - - - - - - - - - - -"

    curl --request POST \
      --url "https://api.render.com/v1/services/$REPLICA_WORDPRESS_SERVICE_ID/suspend" \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer $REPLICA_API_TOKEN"

    curl --request POST \
      --url "https://api.render.com/v1/services/$REPLICA_MYSQL_SERVICE_ID/suspend" \
      --header 'Accept: application/json' \
      --header "Authorization: Bearer $REPLICA_API_TOKEN"
  fi

  cp backup-test-primary.html backup-test-results/backup-test-primary.html
  cp backup-test-replica-domain-replaced.html backup-test-results/backup-test-replica-domain-replaced.html

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Finished testing"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
