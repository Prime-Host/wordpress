#!/bin/bash

# change php user
sed -i s/www-data/$PRIMEHOST_USER/g /usr/local/etc/php-fpm.d/*

# make all user changes only on first creation or if the user changed
if [ ! -f /home/$PRIMEHOST_USER ]; then
  # Create custom ssh_user with sudo privileges
  useradd -m -d /home/$PRIMEHOST_USER -G root -s /bin/zsh $PRIMEHOST_USER \
  && usermod -a -G $PRIMEHOST_USER $PRIMEHOST_USER \
  && usermod -a -G sudo $PRIMEHOST_USER

  # Set passwords for the custom user and root
  echo "$PRIMEHOST_USER:$PRIMEHOST_PASSWORD" | chpasswd
  echo "root:$PRIMEHOST_PASSWORD" | chpasswd
fi

# Wordpress specific changes
if [ ! -f /var/www/html/wp-config.php ]; then
  # Copy wordpress
  mv /usr/src/wordpress/* /var/www/html/.
  chown -R $PRIMEHOST_USER:$PRIMEHOST_USER /var/www/html

  # install wordpress cli
  cd /var/www/html/
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv /var/www/html/wp-cli.phar /usr/local/bin/wp

# setup db connection and create admin user
  sudo -u $PRIMEHOST_USER bash << EOF
  sleep 20
  cd /var/www/html/
  wp config create --dbname=wordpress --dbuser=$PRIMEHOST_USER --dbhost=${PRIMEHOST_DOMAIN}-db --dbpass=$PRIMEHOST_PASSWORD
  wp core install --url=https://${PRIMEHOST_DOMAIN} --title=${PRIMEHOST_DOMAIN} --admin_user=$PRIMEHOST_USER --admin_password=$PRIMEHOST_PASSWORD --admin_email=$LETSENCRYPT_EMAIL
  wp language core install de_DE
  wp site switch-language de_DE
EOF
fi

if ! grep -q "HTTPS" wp-config.php; then
sed -i -e "/table_prefix/a\
\$_SERVER['HTTPS'] = 'on';\ndefine('WP_MEMORY_LIMIT', '2048M');\ndefine('WP_MAX_MEMORY_LIMIT', '2048M');" /var/www/html/wp-config.php
fi

# start all the services
/usr/bin/supervisord
