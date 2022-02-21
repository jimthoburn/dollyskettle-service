#!/bin/sh

# Avoid “Another git process seems to be running in this repository” error
rm -f /root/git-dollyskettle.com/.git/index.lock

# https://docs.netlify.com/cli/get-started/
npm install netlify-cli -g

# https://github.com/netlify/netlify-credential-helper
netlify lm:install

if [ "$WORDPRESS_ENVIRONMENT" = "publish" ]; then

  # Run a script, without waiting for it to finish
  # https://unix.stackexchange.com/questions/86247/what-does-ampersand-mean-at-the-end-of-a-shell-script-line#answer-86253
  sh /usr/local/bin/update-content.sh &

fi

# Hand off to the CMD
exec "$@"
