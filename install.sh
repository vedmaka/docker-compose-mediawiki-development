#!/bin/bash

set -o pipefail

# Downloads and installs selected mediawiki version
TARGET=$1

if [ -z "$TARGET" ]; then
    echo "MediaWiki branch is required as first parameter!"
    exit 1
fi

if [ -d "www/w" ]; then
    echo "Directory www/w already exists!"
    exit 1
fi

echo "Cloning mediawiki.."

git clone -b "$1" --depth 1 https://github.com/wikimedia/mediawiki.git www/w || exit 1
cd www/w || exit 1
git submodule update --init --recursive
cd ../.. || exit 1
cp setup/files/.htaccess www/
cp setup/files/composer.local.json www/w/

echo "Building images.."

# https://docs.docker.com/guides/compose-bake/
# https://docs.docker.com/build/bake/introduction/
# COMPOSE_BAKE=true docker compose build
docker compose build

echo "Starting the stack.."

docker compose up -d

sleep 5

echo "Installing mediawiki.."

docker compose exec webserver php maintenance/install.php \
    --confpath "/var/www/html/w" \
    --dbserver "database" \
    --dbtype "mysql" \
    --dbname "docker" \
    --dbuser "docker" \
    --dbpass "docker" \
    --installdbuser "docker" \
    --installdbpass "docker" \
    --scriptpath "/w" \
    --lang "en" \
    --pass "dockerdocker" \
    --skins "" \
    "mediawiki" \
    "Admin"

echo "Running composer updates.."

docker compose exec webserver composer update

echo "Done!"
