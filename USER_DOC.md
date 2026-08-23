# User documentation

## Services provided

- **NGINX**: serves the website over HTTPS (port 443 only).
- **WordPress + php-fpm**: the CMS powering the website.
- **MariaDB**: the database storing WordPress content and users.

## Start and stop the project

From the root of the repository:

```bash
make up      # build and start everything
make stop    # stop the containers without removing them
make start   # restart stopped containers
make down    # stop and remove containers
```

## Access the website and admin panel

- Website: https://alehamad.42.fr
- Admin panel: https://alehamad.42.fr/wp-admin

Make sure `alehamad.42.fr` is mapped to your VM's IP in your host's
`/etc/hosts` file.

## Credentials

Credentials are stored in `secrets/credentials.txt` (not committed to git).
Database passwords are stored separately in `secrets/db_password.txt` and
`secrets/db_root_password.txt`.

## Check that services are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (nginx, wordpress, mariadb) should show as "Up".