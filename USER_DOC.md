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

Usernames are listed in `secrets/credentials.txt` (not committed to git).
Passwords are stored one-per-file in `secrets/db_password.txt`,
`secrets/db_root_password.txt`, `secrets/wp_admin_password.txt` and
`secrets/wp_editor_password.txt`, each mounted as a Docker secret.

To change a credential, edit the corresponding file in `secrets/` and
recreate the containers so the new value is picked up:

```bash
make down
make up
```

Note that WordPress admin/editor accounts and the database user are only
(re)created on the very first startup of each container (when their volume
is empty). To force a full reset with the new credentials, wipe the
persisted data first:

```bash
make fclean
make up
```

## Check that services are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

All three services (nginx, wordpress, mariadb) should show as "Up".