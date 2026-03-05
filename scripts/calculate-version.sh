#!/bin/bash
set -e

: "${IMAGE_NAME:?IMAGE_NAME not set}"

if [ ! -f VERSION ]; then
  echo "VERSION file missing ❌"
  exit 1
fi

CURRENT_VERSION=$(cat VERSION | tr -d ' \n')

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# increment patch
PATCH=$((PATCH + 1))

# si patch > 9 -> reset patch et increment minor
if [ "$PATCH" -gt 9 ]; then
  PATCH=0
  MINOR=$((MINOR + 1))
fi

# si minor > 9 -> reset minor et increment major
if [ "$MINOR" -gt 9 ]; then
  MINOR=0
  MAJOR=$((MAJOR + 1))
fi

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo "New version: $NEW_VERSION"

echo "$NEW_VERSION" > .new_version
echo "IMAGE_TAG=v$NEW_VERSION" > .image_env