#!/bin/bash
set -e

: "${GITOPS_REPO:?GITOPS_REPO not set}"
: "${GITOPS_PATH:?GITOPS_PATH not set}"
: "${GIT_USER:?GIT_USER not set}"
: "${GIT_PASS:?GIT_PASS not set}"
: "${HARBOR_REGISTRY:?HARBOR_REGISTRY not set}"
: "${HARBOR_PROJECT:?HARBOR_PROJECT not set}"
: "${IMAGE_NAME:?IMAGE_NAME not set}"

source .image_env

FULL_IMAGE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"

rm -rf gitops-repo

git clone https://${GIT_USER}:${GIT_PASS}@${GITOPS_REPO} gitops-repo

cd gitops-repo/${GITOPS_PATH}

sed -i "s|image: .*|image: ${FULL_IMAGE}|" deployment.yaml

git config user.email "ci@jenkins.com"
git config user.name "Jenkins CI"

git add deployment.yaml
git commit -m "chore(deploy): update to ${IMAGE_TAG} [skip ci]" || echo "No change"

git push