#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --skip-networking --socket=/run/mysqld/mysqld.sock &
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping 2>/dev/null; do
        sleep 1
    done

    mysql --socket=/run/mysqld/mysqld.sock -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql --socket=/run/mysqld/mysqld.sock -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql --socket=/run/mysqld/mysqld.sock -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql --socket=/run/mysqld/mysqld.sock -e "FLUSH PRIVILEGES;"
    mysql --socket=/run/mysqld/mysqld.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

<<<<<<< HEAD
exec mysqld_safe
=======
mysqld_safe --datadir=/var/lib/mysql &

until mysqladmin ping --silent 2>/dev/null; do
    sleep 1
done

mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

if [ ! -f /var/lib/mysql/.root_configured ]; then
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    touch /var/lib/mysql/.root_configured
fi

mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

exec mysqld_safe --datadir=/var/lib/mysql
>>>>>>> 48708af34c27cbe0aa9f5863151fe0fad091304e
