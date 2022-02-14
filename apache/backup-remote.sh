#!/bin/sh

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting backup"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /var/www"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /var/www

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Configure Git"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git config --global user.email $GITHUB_USER_EMAIL
git config --global user.name "$GITHUB_USER_NAME"
git lfs install

rm -rf /var/www/.ssh
mkdir /var/www/.ssh
cp /etc/secrets/id_ed25519 /var/www/.ssh/id_ed25519
cp /etc/secrets/id_ed25519.pub /var/www/.ssh/id_ed25519.pub
cp /etc/secrets/known_hosts /var/www/.ssh/known_hosts

# https://unix.stackexchange.com/questions/31947/how-to-add-a-newline-to-the-end-of-a-file
sed -i -e '$a\' /var/www/.ssh/id_ed25519
sed -i -e '$a\' /var/www/.ssh/id_ed25519.pub
sed -i -e '$a\' /var/www/.ssh/known_hosts

chmod 600 /var/www/.ssh/id_ed25519
chmod 600 /var/www/.ssh/id_ed25519.pub
chmod 600 /var/www/.ssh/known_hosts

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Put site in maintenance mode"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "<?php \$upgrading = time(); ?>" > /var/www/git-wordpress/html/.maintenance

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Get latest WordPress database from remote host"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Open an SSH tunnel to a remote host and use to download the latest database
#
# https://stackoverflow.com/questions/2989724/how-to-mysqldump-remote-db-from-local-machine
# https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding

eval "$(ssh-agent -s)"

# 1. `-L` Open an SSH tunnel to user@remote-host
# 2. `-f` Fork the connection so a local prompt is used
# 3. `-4` Use ipv4
# 4. Forward requests from local computer (127.0.0.1:3310) to remote-database-host:3306
# 5. `sleep 10` Automatically close the tunnel after 10 seconds, or after the mysqldump is finished
#
# https://www.g-loaded.eu/2006/11/24/auto-closing-ssh-tunnels/
# https://serverfault.com/questions/444295/ssh-tunnel-bind-cannot-assign-requested-address
ssh \
  -4 \
  -f -L \
  3310:$REMOTE_WORDPRESS_DB_HOST:3306 \
  $REMOTE_WORDPRESS_SSH_USER@$REMOTE_WORDPRESS_SSH_HOST \
  sleep 10; \
mysqldump \
  -P 3310 \
  -h 127.0.0.1 \
  -u $REMOTE_WORDPRESS_DB_USER \
  --password=$REMOTE_WORDPRESS_DB_PASSWORD \
  --single-transaction --no-tablespaces \
  --result-file=/var/www/git-wordpress/wordpress-database.sql \
  $REMOTE_WORDPRESS_DB_NAME

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Get latest WordPress files from remote host with LFTP"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

# https://superuser.com/questions/40281/how-do-i-get-an-entire-directory-in-sftp#answer-726866
# lftp sftp://user:password@server.org:22 -e 'mirror --verbose --use-pget-n=8 -c /remote/path /local/path'
#
# https://askubuntu.com/questions/61429/how-do-i-execute-ftp-commands-on-one-line
# `-e` will keep you connected unless you issue a quit (or exit)
# `--continue` continue a mirror job if possible
# `--ignore-time` ignore timestamps when deciding which files have changed
# `ftp:use-mdtm-overloaded` preserve a file's original date and time information after file transfer
# https://stackoverflow.com/questions/3892147/how-to-preserve-file-modification-time-with-lftp
# https://support.solarwinds.com/SuccessCenter/s/article/MDTM-FTP-command?language=en_US
(
 echo connect "sftp://$REMOTE_WORDPRESS_SSH_USER:$REMOTE_WORDPRESS_SSH_PASSWORD@$REMOTE_WORDPRESS_SSH_HOST:22"
 echo mirror --verbose "$REMOTE_WORDPRESS_FILE_PATH" "/var/www/git-wordpress/html"
 echo bye
) | lftp -f /dev/stdin

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "cd to /var/www/git-wordpress"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

cd /var/www/git-wordpress

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Check changed files into the repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

eval "$(ssh-agent -s)"
git add .

# Reset config files meant for the remote host
# https://stackoverflow.com/questions/7147270/hard-reset-of-a-single-file
git checkout HEAD -- html/.htaccess
git checkout HEAD -- html/wp-config.php

git commit -m "Automatic commit with the latest content"
git pull --rebase

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Update local MySQL database"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

echo "drop database wordpress; create database wordpress;" > delete-wordpress.sql

mysql \
-h $WORDPRESS_DB_HOST \
-u $WORDPRESS_DB_USER \
--password=$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME \
< /var/www/git-wordpress/delete-wordpress.sql

rm delete-wordpress.sql

mysql \
-h $WORDPRESS_DB_HOST \
-u $WORDPRESS_DB_USER \
--password=$WORDPRESS_DB_PASSWORD $WORDPRESS_DB_NAME \
< /var/www/git-wordpress/wordpress-database.sql

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Put site back in non-maintenance mode"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

rm /var/www/git-wordpress/html/.maintenance

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Push commits to remote repository"
echo "- - - - - - - - - - - - - - - - - - - - - - -"

git push origin

echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "Finished backing up"
echo "- - - - - - - - - - - - - - - - - - - - - - -"
