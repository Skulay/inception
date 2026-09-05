#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)

mkdir -p /run/php

cd /var/www/html

if [ ! -f wp-config.php ]; then
    until (echo > /dev/tcp/mariadb/3306) 2>/dev/null; do
        sleep 1
    done

    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=boss \
        --admin_password=adminpass123 \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create editeur editeur@${DOMAIN_NAME} \
        --role=editor \
        --user_pass=editpass123 \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

exec php-fpm7.4 -F