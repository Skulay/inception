FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx-light \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=alehamad.42.fr"

# -x509 : certificat auto-signé
# -nodes : la clé privée n'est pas chiffrée par un mdp
# -subj : remplit les champs du certificat, CN = nom de domaine

COPY conf/nginx.conf /etc/nginx/nginx.conf
#remplace la config par la mienne

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
#lance nginx en foreground (PID 1)