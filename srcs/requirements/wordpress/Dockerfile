FROM debian:bullseye

RUN sed -i \
    -e 's|^deb http://deb\.debian\.org|# deb http://deb.debian.org|' \
    -e 's|^# deb http://snapshot\.debian\.org|deb [check-valid-until=no] http://snapshot.debian.org|' \
    /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 9000

ENTRYPOINT ["/init.sh"]