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
git submodule foreach --recursive 'git fetch --unshallow || echo "Already full"'

## 3. (Optional) Update submodules to latest remote commits
git submodule update --remote --merge --recursive
