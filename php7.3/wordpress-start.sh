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
  # Download wordpress
  cd /var/www/html/ \
  && curl -o latest.tar.gz -fSL "https://wordpress.org/latest.tar.gz" \
  && tar xvf latest.tar.gz \
  && mv wordpress/* . \
  && rm -r wordpress latest.tar.gz \
  && chown -R $PRIMEHOST_USER:$PRIMEHOST_USER /var/www/html

  # install wordpress cli
  cd /var/www/html/
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv /var/www/html/wp-cli.phar /usr/local/bin/wp

# setup db connection and create admin user
sudo -u $PRIMEHOST_USER bash << EOF
  cd /var/www/html/
  sleep 3
  /usr/local/bin/wp config create --dbname=wordpress --dbuser=$PRIMEHOST_USER --dbhost=${PRIMEHOST_DOMAIN}-db --dbpass=$PRIMEHOST_PASSWORD
  /usr/local/bin/wp core install --url=https://${PRIMEHOST_DOMAIN} --title=${PRIMEHOST_DOMAIN} --admin_user=$PRIMEHOST_USER --admin_password=$PRIMEHOST_PASSWORD --admin_email=$LETSENCRYPT_EMAIL
EOF
fi

if grep -q "HTTPS" wp-config.php; then
  echo "HTTPS already active"
else
  sed -i -e "/table_prefix/a\
\$_SERVER['HTTPS'] = 'on';" /var/www/html/wp-config.php
fi

# start all the services
/usr/bin/supervisord
