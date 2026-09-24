FROM debian:bookworm 
#derniere version stable donc != latest

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*
# vide le datadir installé par le paquet, un volume sera monter a l'execution

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["/init.sh"]