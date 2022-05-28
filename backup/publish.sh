#!/bin/bash

if [ "$WORDPRESS_ENVIRONMENT" = "remote-backup" ]; then

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Start publishing service"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

  # curl -X POST -d '{}' "$PUBLISH_DEPLOY_HOOK"

  curl --request POST \
    --url "https://api.render.com/v1/services/$PUBLISH_SERVICE_ID/resume" \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $PUBLISH_API_TOKEN"

  echo "- - - - - - - - - - - - - - - - - - - - - - -"
  echo "Finished starting publishing service"
  echo "- - - - - - - - - - - - - - - - - - - - - - -"

fi
