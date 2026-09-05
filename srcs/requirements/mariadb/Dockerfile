FROM debian:bullseye

RUN sed -i \
    -e 's|^deb http://deb\.debian\.org|# deb http://deb.debian.org|' \
    -e 's|^# deb http://snapshot\.debian\.org|deb [check-valid-until=no] http://snapshot.debian.org|' \
    /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["/init.sh"]