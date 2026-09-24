# Developer documentation

## Prerequisites

- A virtual machine (Debian or Alpine based host)
- Docker and Docker Compose installed
- The `secrets/` folder created at the root with:
  - `db_password.txt`
  - `db_root_password.txt`
  - `wp_admin_password.txt`
  - `wp_editor_password.txt`

## Environment setup

Create `srcs/.env` with the following variables:

```env
DOMAIN_NAME=alehamad.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN_EMAIL=admin@alehamad.42.fr
```

Neither `.env` nor `secrets/*.txt` should ever be committed (see `.gitignore`).

## Build and launch

```bash
make up
```

This runs `docker compose -f srcs/docker-compose.yml up -d --build`, which
builds the three Dockerfiles (nginx, wordpress, mariadb) and starts the
containers on the `inception` network.

## Makefile targets

```bash
make up        # build (if needed) and start all containers, detached
make down      # stop and remove containers (volumes are kept)
make stop      # pause containers without removing them
make start     # resume containers paused with `make stop`
make restart   # down then up
make clean     # down + prune unused Docker images/containers/networks
make fclean    # clean + wipe the content of the host data directories (full data reset)
make re        # fclean + up (full rebuild from scratch)
```

## Managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps           # list running services and their status
docker compose -f srcs/docker-compose.yml logs -f       # follow logs of all services
docker compose -f srcs/docker-compose.yml logs -f nginx # follow logs of a single service
docker compose -f srcs/docker-compose.yml down          # stop and remove containers
docker volume ls                                        # list named volumes
docker volume inspect srcs_wordpress_data                # check a volume's host-backing path
docker volume inspect srcs_mariadb_data
docker network ls                                        # list Docker networks
docker network inspect srcs_inception                     # list containers attached + their internal IPs
docker exec -it nginx bash                                # shell into a container
docker exec -it wordpress bash
docker exec -it mariadb bash
```

## Accessing the website

Make sure `<login>.42.fr` (e.g. `alehamad.42.fr`) is mapped to the VM's IP
in `/etc/hosts` on the machine you're browsing from, then:

```bash
# In a browser:
https://alehamad.42.fr           # the WordPress site
https://alehamad.42.fr/wp-admin  # the admin dashboard (login: boss)

# From the command line (self-signed cert, -k skips verification):
curl -kI https://alehamad.42.fr           # should return HTTP/2 200
curl -kI http://alehamad.42.fr            # should fail/refuse, port 80 isn't served
```

## Connecting to MariaDB

```bash
docker exec -it mariadb mysql -u wpuser -p wordpress
# password: content of secrets/db_password.txt

docker exec -it mariadb mysql -u root -p
# password: content of secrets/db_root_password.txt
```

Once connected, useful SQL to check the database isn't empty:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT ID, user_login, user_email FROM wp_users;
```

## Inspecting WordPress (wp-cli)

`wp-cli` is installed in the wordpress container and can be used to inspect
or manage the install without going through the web UI:

```bash
docker exec -it wordpress bash
cd /var/www/html
wp user list --allow-root
wp plugin list --allow-root
wp option get siteurl --allow-root
```

## Data persistence

- WordPress files persist in the `wordpress_data` named volume, backed by
  `/home/alehamad/data/wordpress` on the host.
- The MariaDB database persists in the `mariadb_data` named volume, backed by
  `/home/alehamad/data/mariadb` on the host.

Both directories must exist before the first `make up`:

```bash
mkdir -p /home/alehamad/data/wordpress
mkdir -p /home/alehamad/data/mariadb
```