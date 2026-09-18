# MediaWiki Docker development environment

This is a Docker Compose setup for MediaWiki development. It clones the MediaWiki branch you choose into `www/w`, so you can edit the source on the host and run it against different PHP and database versions.

- **Choose a branch:** `install.sh` clones the MediaWiki branch you pass to it
- **Choose PHP:** images are included for PHP 5.4, 5.6, 7.1–7.4, 8.0, 8.1, and 8.2
- **Choose a database:** MySQL 5.7 and 8, and MariaDB 10.3–10.6 are available
- **Use local tooling:** Redis, a MediaWiki job runner, MailHog, Caddy, and Xdebug are included
- **Edit on the host:** MediaWiki lives in `www/w` and is mounted into the web container

```bash
cp .env.example .env
# Set PHPVERSION=php81 in .env
./install.sh REL1_43
# MediaWiki: http://localhost
# Login: Admin / dockerdocker
```

> This setup uses development credentials and is intended for local development only

## Contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Xdebug](#xdebug)
- [Export pages](#export-pages)
- [Convert a shallow clone](#convert-a-shallow-clone)
- [Clean up](#clean-up)

## Requirements

- Git
- Docker with the Compose plugin
- Bash

Make sure ports `80`, `3306`, `6379`, and `8025` are available, or change them in `.env`

## Quick start

1. Clone this repository and enter its directory

2. Create your local configuration

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and select PHP and database versions suitable for your target MediaWiki branch

   For the `REL1_43` example, use PHP 8.1:

   ```dotenv
   PHPVERSION=php81
   ```

   On Apple Silicon, use one of the MariaDB options listed in `.env.example`

4. Run the installer with a MediaWiki branch or tag

   ```bash
   ./install.sh REL1_43
   ```

   Replace `REL1_43` with the branch or tag you want to use

5. Open <http://localhost> and sign in

   ```text
   Username: Admin
   Password: dockerdocker
   ```

The installer clones MediaWiki and its submodules into `www/w`, builds the images, starts the stack, runs the MediaWiki installer, and updates Composer dependencies

The installer expects a clean checkout. It stops if `www/w` already exists

## Configuration

Copy `.env.example` to `.env` before changing any defaults

| Setting | Default | Purpose |
| --- | --- | --- |
| `PHPVERSION` | `php74` | PHP image built for the web container |
| `DATABASE` | `mariadb105` | Database image |
| `HOST_MACHINE_UNSECURE_HOST_PORT` | `80` | MediaWiki HTTP port |
| `HOST_MACHINE_MYSQL_PORT` | `3306` | Database port, bound to `127.0.0.1` |
| `HOST_MACHINE_REDIS_PORT` | `6379` | Redis port, bound to `127.0.0.1` |
| `HOST_MAILHOG_WEB_PORT` | `8025` | MailHog web interface, bound to `127.0.0.1` |
| `PHP_XDEBUG_MODE` | `off` | Xdebug modes passed to PHP |

Useful local addresses with the default configuration:

- MediaWiki: <http://localhost>
- MailHog: <http://localhost:8025>

The installer currently uses the default database name, user, and password from `.env.example`: `docker`, `docker`, and `docker`

## Xdebug

Enable Xdebug in `.env`:

```dotenv
PHP_XDEBUG_MODE=debug
PHP_XDEBUG_START_WITH_REQUEST=yes
```

Restart the web container after changing the configuration:

```bash
docker compose up -d --force-recreate webserver
```

Xdebug connects to `host.docker.internal` on port `9003`. In PhpStorm, map the local `www/w` directory to `/var/www/html/w` and use the server name `localhost`

## Export pages

Export current pages from the main namespace:

```bash
docker compose exec webserver php maintenance/dumpBackup.php \
  --current \
  --report 1 \
  --filter=namespace:0 > pagedump.xml
```

The dump is written to `pagedump.xml` on the host

## Convert a shallow clone

The installer creates a shallow MediaWiki checkout. Fetch the full history when you need it:

```bash
git -C www/w fetch --unshallow
git -C www/w submodule foreach --recursive \
  'git fetch --unshallow || echo "Already full"'
```

To move submodules to their latest remote commits:

```bash
git -C www/w submodule update --remote --merge --recursive
```

## Clean up

```bash
./cleanup.sh
```

> `cleanup.sh` permanently removes the MediaWiki checkout, logs, database data, and Docker volumes after confirmation
