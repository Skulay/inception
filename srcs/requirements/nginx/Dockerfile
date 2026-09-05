FROM debian:bullseye

RUN sed -i \
    -e 's|^deb http://deb\.debian\.org|# deb http://deb.debian.org|' \
    -e 's|^# deb http://snapshot\.debian\.org|deb [check-valid-until=no] http://snapshot.debian.org|' \
    /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    nginx-light \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=alehamad.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]