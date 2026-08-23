*This project has been created as part of the 42 curriculum by alehamad.*

## Description

Inception is a system administration project that consists of setting up a small
web infrastructure using Docker Compose. Three services run each in their own
container: NGINX (with TLS only), WordPress with php-fpm, and MariaDB. Data is
persisted through Docker named volumes and everything is orchestrated on a
dedicated Docker network.

## Instructions

1. Clone the repo on your virtual machine.
2. Create the secrets files in `secrets/` (see DEV_DOC.md).
3. Add `<your_ip> alehamad.42.fr` to `/etc/hosts` on your host.
4. Run `make` at the root of the project.
5. Visit `https://alehamad.42.fr` in your browser.

See USER_DOC.md and DEV_DOC.md for more details.

## Project description

This project uses Docker instead of a full virtual machine per service because
containers are much lighter (they share the host kernel instead of virtualizing
an entire OS), start faster, and use less disk/RAM, while still isolating each
service's dependencies. The whole infrastructure still runs inside one VM as
required by the subject.

- **Secrets vs Environment variables**: environment variables in a `.env` file
  are convenient but end up visible in `docker inspect` and in process
  environments. Docker secrets are mounted as files in `/run/secrets/` inside
  the container and are not persisted in the image layers, so passwords use
  secrets while non-sensitive config (domain name, DB name/user) stays in `.env`.
- **Docker network vs host network**: `network: host` would remove the network
  isolation between containers and the host, defeating the purpose of
  containerization and is forbidden by the subject. A dedicated bridge network
  lets the containers resolve each other by service name while staying
  isolated from the host network.
- **Docker volumes vs bind mounts**: named volumes are managed by Docker and
  are more portable/robust for persistent data like a database or WordPress
  files. The subject requires named volumes (with backing storage under
  `/home/login/data`) rather than raw bind mounts.

## Resources

- Docker official documentation: https://docs.docker.com/
- WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- NGINX documentation: https://nginx.org/en/docs/

AI (Claude) was used to help debug SSH access to the VM through VirtualBox/WSL,
to review and fix syntax errors in the Dockerfiles, nginx.conf and
docker-compose.yml, and to help structure the mandatory part according to the
subject's requirements. All generated code was reviewed, tested, and adjusted
manually before being used.