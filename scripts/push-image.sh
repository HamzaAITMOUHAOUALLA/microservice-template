#!/bin/bash
set -e

: "${IMAGE_NAME:?IMAGE_NAME not set}"
#: "${HARBOR_REGISTRY:?HARBOR_REGISTRY not set}"
#: "${HARBOR_PROJECT:?HARBOR_PROJECT not set}"
#: "${HARBOR_USER:?HARBOR_USER not set}"
#: "${HARBOR_PASS:?HARBOR_PASS not set}"

source .image_env

FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

echo "Building ${FULL_IMAGE}..."

docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

#docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE}

#echo "$HARBOR_PASS" | docker login ${HARBOR_REGISTRY} -u "$HARBOR_USER" --password-stdin

#docker push ${FULL_IMAGE}

#docker logout ${HARBOR_REGISTRY}

#echo "Image pushed: ${FULL_IMAGE}"