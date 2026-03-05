#!/bin/bash
set -e

: "${GIT_USER:?GIT_USER not set}"
: "${GIT_PASS:?GIT_PASS not set}"
: "${SOURCE_REPO:?SOURCE_REPO not set}"

NEW_VERSION=$(cat .new_version)

git config user.email "ci@jenkins.com"
git config user.name "Jenkins CI"

#  synchroniser avant modification
git pull origin main --rebase || true

#  update version
echo $NEW_VERSION > VERSION

git add VERSION
git commit -m "Bump version to v$NEW_VERSION [skip ci]" || echo "No change"

#  push
git push https://${GIT_USER}:${GIT_PASS}@${SOURCE_REPO} main