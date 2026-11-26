*This project has been created as part of the 42 curriculum by alehamad.*

# Inception

A small web infrastructure (NGINX, WordPress and MariaDB) built from scratch with Docker Compose, one service per container.

![tool](https://img.shields.io/badge/tool-Docker%20Compose-000000?style=flat-square)
![school](https://img.shields.io/badge/school-42-000000?style=flat-square)
![base](https://img.shields.io/badge/base-Debian%20bookworm-000000?style=flat-square)

## Overview

**Inception** sets up a WordPress website served over HTTPS, inside a virtual machine, with three containers built from my own Dockerfiles (no ready-made images from Docker Hub other than the Debian base):

- **NGINX**, the only entry point, with TLS 1.2 / 1.3
- **WordPress** with **php-fpm**, installed and configured automatically with `wp-cli`
- **MariaDB**, the database

The goal of the project is to understand:

- how to write a **Dockerfile** and build an image for a single service
- how **Docker Compose** builds, starts and connects several containers
- how containers talk to each other through a private **network**
- how data survives a restart with **volumes**
- how to pass passwords to a container safely with **Docker secrets**
- how NGINX forwards PHP requests to php-fpm with **FastCGI**

## Features

### Services

| Service | Image | Role | Port |
|---|---|---|---|
| `nginx` | Debian bookworm + `nginx-light`, `openssl` | HTTPS only, self-signed certificate for `alehamad.42.fr`, forwards `.php` to WordPress | `443` (published on the host as `8443`) |
| `wordpress` | Debian bookworm + `php-fpm`, `php-mysql`, `wp-cli` | Runs WordPress, creates `wp-config.php`, the site and two users on first start | `9000`, internal |
| `mariadb` | Debian bookworm + `mariadb-server` | Creates the database, its user and the root password on first start | `3306`, internal |

### Infrastructure

| Feature | Details |
|---|---|
| Network | One `bridge` network `inception`; containers reach each other by service name (`wordpress:9000`, `mariadb:3306`) |
| Volumes | `wordpress_data` and `mariadb_data`, stored on the host in `/home/alehamad/data/` |
| Secrets | Four passwords mounted as files in `/run/secrets/`, never written in an image or in `.env` |
| Restart policy | `unless-stopped`: a container that crashes is restarted |
| PID 1 | Each service runs in the foreground (`nginx -g 'daemon off;'`, `php-fpm8.2 -F`, `mysqld_safe`), no `tail -f` or infinite loop |
| WordPress users | An administrator (`boss`) and an author (`editeur`) |

## Build

### Requirements

- A virtual machine running Linux
- Docker and Docker Compose
- `make`, `sudo`, `openssl` (to generate passwords)

### Make rules

| Rule | Action |
|---|---|
| `make` / `make up` | Build the images if needed and start the containers in the background |
| `make down` | Stop and remove the containers (volumes are kept) |
| `make stop` / `make start` | Pause / resume the containers without removing them |
| `make restart` | `down` then `up` |
| `make clean` | `down`, then `docker system prune -af` |
| `make fclean` | `clean`, then delete the content of `/home/alehamad/data/` (full data reset) |
| `make re` | `fclean` then `up` |

## How to use

The passwords and the `.env` file are not in the repository: they have to be created on the VM before the first start.

### 1. Clone the repository

```bash
git clone <repository-url> inception
cd inception
```

### 2. Create the data folders

The two volumes are stored there; they must exist before the first `make`:

```bash
mkdir -p /home/alehamad/data/wordpress /home/alehamad/data/mariadb
```

### 3. Create the `.env` file

Non-sensitive settings only:

```bash
cat > srcs/.env << 'EOF'
DOMAIN_NAME=alehamad.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_ADMIN_EMAIL=admin@alehamad.42.fr
EOF
```

### 4. Create the secrets

One password per file, without a trailing newline. To generate random ones:

```bash
mkdir -p secrets
for f in db_password db_root_password wp_admin_password wp_editor_password; do
    openssl rand -base64 18 | tr -d '\n' > secrets/$f.txt
done
chmod 600 secrets/*.txt
```

| File | Used by |
|---|---|
| `secrets/db_password.txt` | MariaDB user `wpuser`, and WordPress to connect to the database |
| `secrets/db_root_password.txt` | MariaDB `root` |
| `secrets/wp_admin_password.txt` | WordPress administrator `boss` |
| `secrets/wp_editor_password.txt` | WordPress author `editeur` |

### 5. Point the domain to the VM

On the machine you browse from, add this line to `/etc/hosts`:

```
<vm_ip>  alehamad.42.fr
```

Use `127.0.0.1` if the browser runs inside the VM.

### 6. Start

```bash
make
```

The first start takes a while: the images are built, then MariaDB and WordPress are installed. Check that the three containers are `Up`:

```bash
docker compose -f srcs/docker-compose.yml ps
```

### 7. Open the website

| Page | URL | Login |
|---|---|---|
| Website | `https://alehamad.42.fr:8443` | none |
| Admin panel | `https://alehamad.42.fr:8443/wp-admin` | `boss` / content of `secrets/wp_admin_password.txt` |
| Author account | `https://alehamad.42.fr:8443/wp-admin` | `editeur` / content of `secrets/wp_editor_password.txt` |

The certificate is self-signed, so the browser shows a warning the first time: accept it to continue.

### 8. Stop, restart, reset

```bash
make stop       # pause, everything is kept
make start      # resume
make down       # remove the containers, the data is kept
make            # start again, the site is still there
make re         # wipe everything and reinstall from scratch
```

Changing a password in `secrets/` only takes effect on a fresh install (`make re`): the users and the database are only created on the first start.

More details are in two separate documents:

- [USER_DOC.md](USER_DOC.md): starting and stopping the project, accessing the site, changing credentials
- [DEV_DOC.md](DEV_DOC.md): containers, volumes, database and `wp-cli` commands

## How it works

```
   browser
      │ HTTPS (TLS 1.2 / 1.3)
      ▼
 ┌──────────┐  FastCGI :9000  ┌──────────────┐   SQL :3306   ┌──────────┐
 │  nginx   │ ──────────────► │  wordpress   │ ────────────► │ mariadb  │
 │  :443    │                 │  php-fpm     │               │          │
 └──────────┘                 └──────────────┘               └──────────┘
      │                              │                             │
      └──────── wordpress_data ──────┘                       mariadb_data
             /home/alehamad/data/wordpress           /home/alehamad/data/mariadb

                         network: inception (bridge)
```

### 1. MariaDB — `srcs/requirements/mariadb/`

The image installs `mariadb-server` and empties its data folder, since the volume is mounted at run time. On the first start only (`/var/lib/mysql/mysql` does not exist yet), `init.sh`:

1. initialises the data folder with `mysql_install_db`
2. starts a temporary server **without networking**, waits for it with `mysqladmin ping`
3. creates the database and the user, gives it the rights on that database, sets the root password
4. shuts the temporary server down

Then it runs the real server with `exec mysqld_safe`, so it becomes PID 1. `50-server.cnf` makes it listen on `0.0.0.0:3306`, reachable from the other containers only.

### 2. WordPress — `srcs/requirements/wordpress/`

The image installs `php-fpm`, downloads WordPress and `wp-cli`. `www.conf` makes php-fpm listen on port `9000`. On the first start (no `wp-config.php` yet), `init.sh`:

1. waits until `mariadb:3306` accepts TCP connections
2. writes `wp-config.php` with `wp config create`
3. installs the site and its administrator with `wp core install`
4. creates the second user with `wp user create … --role=author`

Then it runs `exec php-fpm8.2 -F` in the foreground.

### 3. NGINX — `srcs/requirements/nginx/`

The image generates a self-signed certificate for `alehamad.42.fr` with `openssl` at build time. `nginx.conf` only listens on `443` with `ssl_protocols TLSv1.2 TLSv1.3`, serves static files from the shared WordPress volume, and sends every `.php` request to `wordpress:9000` with `fastcgi_pass`.

### 4. Compose — `srcs/docker-compose.yml`

Declares the three services, the network, the two volumes (stored in `/home/alehamad/data/`) and the four secrets. `depends_on` starts MariaDB first, then WordPress, then NGINX.

## Design choices

### Virtual machines vs Docker

A virtual machine emulates a whole computer with its own kernel; a container is an isolated process that shares the host's kernel. Containers are much lighter: they start in seconds and use far less disk and RAM, while still isolating each service and its dependencies. The whole infrastructure still runs inside one VM, as the subject requires.

### Secrets vs environment variables

Variables in a `.env` file are convenient, but they show up in `docker inspect` and in the environment of every process of the container. Docker secrets are mounted as files in `/run/secrets/` and are never stored in the image layers. Passwords therefore use secrets, while non-sensitive settings (domain name, database name and user, email) stay in `.env`.

### Docker network vs host network

`network: host` would remove the isolation between the containers and the host, and is forbidden by the subject. A dedicated bridge network lets the containers find each other by service name while staying cut off from the host network; only NGINX publishes a port.

### Docker volumes vs bind mounts

Named volumes are managed by Docker, which makes them more portable and robust for persistent data like a database or WordPress files. The subject requires named volumes, with their data stored in `/home/login/data` on the host.

## Project structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md                  # how to use the project
├── DEV_DOC.md                   # how to set it up and work on it
├── secrets/                     # passwords, one per file (not versioned)
└── srcs/
    ├── .env                     # non-sensitive settings (not versioned)
    ├── docker-compose.yml       # services, network, volumes, secrets
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile       # nginx-light + self-signed certificate
        │   └── conf/nginx.conf  # TLS, FastCGI to wordpress:9000
        ├── wordpress/
        │   ├── Dockerfile       # php-fpm, WordPress, wp-cli
        │   ├── conf/www.conf    # php-fpm listens on 9000
        │   └── tools/init.sh    # wp-config, install, users
        └── mariadb/
            ├── Dockerfile       # mariadb-server
            ├── conf/50-server.cnf
            └── tools/init.sh    # database, user, root password
```

## Examples

```console
$ make
$ docker compose -f srcs/docker-compose.yml ps
NAME        IMAGE       ...   STATUS
mariadb     mariadb     ...   Up
nginx       nginx       ...   Up
wordpress   wordpress   ...   Up

$ curl -kI https://alehamad.42.fr:8443
HTTP/1.1 200 OK

$ docker exec -it mariadb mysql -u wpuser -p wordpress -e "SELECT user_login FROM wp_users;"
+------------+
| user_login |
+------------+
| boss       |
| editeur    |
+------------+
```

## Testing

- `make re` from an empty data folder, then a full check of the site and the admin panel
- `make down` then `make up`: posts, comments and users must still be there
- `docker kill` on a container: it must restart by itself
- HTTP on port 80 must be refused, only HTTPS works
- `docker inspect` must not show any password

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/reference/compose-file/)
- [WP-CLI commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)

**AI use**: AI (Claude) was used to help review and fix syntax errors in the Dockerfiles, `nginx.conf` and `docker-compose.yml`. Everything was reviewed, tested and adjusted by hand before being used.

## Author

| Login | Work |
|---|---|
| **alehamad** | Everything |
