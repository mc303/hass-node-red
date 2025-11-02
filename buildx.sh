#!/usr/bin/env bash

# DOCKER_REPO="ghcr.io/mc303/hass-node-red:latest"
# BUIILDX_REPO='buildhassnodered'
# BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"

DOCKER_USER_REPO=node-red/node-red 
DOCKER_API_URL=https://api.github.com/repos/${DOCKER_USER_REPO}/releases/latest
CONTAINER_VERSION=$(curl --silent ${DOCKER_API_URL} | jq -r '.tag_name')
# CONTAINER_CURRENT_VERSION=$(docker run --rm quay.io/skopeo/stable list-tags docker://ghcr.io/mc303/caddy-transip | jq '.Tags[-1]' | tr -d '"')
CONTAINER_NAME="ghcr.io/mc303/hass-node-red:latest"
CONTAINER_NAME_TAG_VERSION="ghcr.io/mc303/hass-node-red:${CONTAINER_VERSION}"
BUIILDX_REPO='build-hass-node-red'
BUILD_PLATFORM="linux/amd64,linux/arm64"

echo ${DOCKER_USER_REPO}
echo ${DOCKER_API_URL}
echo ${CONTAINER_VERSION}
# echo ${CADDY_CURRENT_VERSION}
echo ${DOCKER_REPO}
echo ${CONTAINER_NAME_TAG_VERSION}
echo ${BUIILDX_REPO}
echo ${BUILD_PLATFORM}


echo "docker buildx build . --platform=${BUILD_PLATFORM} --tag ${CONTAINER_NAME} --tag ${CONTAINER_NAME_TAG_VERSION} --push"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

#create multiplatform environment
docker buildx create --platform=${BUILD_PLATFORM} --name ${BUIILDX_REPO}
docker buildx use ${BUIILDX_REPO}

#build multiplatform docker image
docker buildx build . --platform=${BUILD_PLATFORM} --tag ${CONTAINER_NAME} --tag ${CONTAINER_NAME_TAG_VERSION} --push

#remove multiplatform environment
docker buildx rm ${BUIILDX_REPO}



