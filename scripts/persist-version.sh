#!/bin/bash
set -e

: "${GIT_USER:?GIT_USER not set}"
: "${GIT_PASS:?GIT_PASS not set}"
: "${SOURCE_REPO:?SOURCE_REPO not set}"

# récupérer version calculée
NEW_VERSION=$(cat .new_version)

echo "Persisting version: $NEW_VERSION"

# mettre à jour fichier VERSION
echo "$NEW_VERSION" > VERSION

# config git
git config user.email "ci@jenkins.com"
git config user.name "Jenkins CI"

# commit
git add VERSION
git commit -m "Bump version to v$NEW_VERSION [skip ci]" || echo "No change"

# push
git push https://${GIT_USER}:${GIT_PASS}@${SOURCE_REPO} main

echo "Version persisted successfully ✅"