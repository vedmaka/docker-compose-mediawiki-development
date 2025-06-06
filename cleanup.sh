#!/bin/bash

set -o pipefail

echo "WARNING: This will delete all data including database and webroot files!"
echo -n "Type 'yes' to continue: "
read confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup aborted."
    exit 1
fi

echo "Cleaning up everything.."

rm -rf www/w
rm -rf www/.htaccess

find logs/apache2 -type f ! -name '.gitignore' -delete
find logs/mysql -type f ! -name '.gitignore' -delete
find logs/xdebug -type f ! -name '.gitignore' -delete
find data/mysql -type f ! -name '.gitignore' -delete
find data/mysql -type d -delete

docker compose down -v

echo "Done!"
