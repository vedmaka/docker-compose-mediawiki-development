# Quick start

* Clone the repo
* Copy `.env.example` to `.env`
* Verify that the PHP version in `.env` matches your target MediaWiki version
* Run `./install.sh`
* Enjoy!

# Convert Shallow Git Clone to Full Clone (with Submodules)

## 1. Unshallow the main repository
git fetch --unshallow

## 2. Unshallow all submodules
git submodule foreach --recursive `git fetch --unshallow || echo "Already full"`

## 3. (Optional) Update submodules to latest remote commits
git submodule update --remote --merge --recursive

# Xdebug

Control with `PHP_XDEBUG_MODE=off` environment variable. Port is by `XDEBUG_PORT`
For Xdebug to work in PHPStorm, you need to set the path mappings.

# Exporting

```bash
docker compose exec webserver php maintenance/dumpBackup.php --current --report 1 --filter=namespace:0 > pagedump.xml
```
