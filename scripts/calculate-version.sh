#!/bin/bash
set -e

: "${IMAGE_NAME:?IMAGE_NAME not set}"

if [ ! -f VERSION ]; then
  echo "VERSION file missing ❌"
  exit 1
fi

CURRENT_VERSION=$(cat VERSION | tr -d ' \n')

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

PATCH=$((PATCH + 1))

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo "New version: $NEW_VERSION"

echo $NEW_VERSION > .new_version
echo "IMAGE_TAG=v$NEW_VERSION" > .image_env