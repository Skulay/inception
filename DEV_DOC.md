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

## Managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps        # list running services
docker compose -f srcs/docker-compose.yml logs -f    # follow logs
docker volume ls                                     # list named volumes
docker exec -it mariadb bash                          # shell into a container
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