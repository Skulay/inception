#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_EDITOR_PASSWORD=$(cat /run/secrets/wp_editor_password)

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
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    wp user create editeur editeur@${DOMAIN_NAME} \
        --role=editor \
        --user_pass=${WP_EDITOR_PASSWORD} \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

mkdir -p /run/php
exec php-fpm8.2 -F
