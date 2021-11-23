#!/bin/sh

DOCKER_REPO="ghcr.io/mc303/hass-node-red:latest"
BUIILDX_REPO='buildhassnodered'
BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

#create multiplatform environment
docker buildx create --platform=${BUILD_PLATFORM} --name ${BUIILDX_REPO}
docker buildx use ${BUIILDX_REPO}

#build multiplatform docker image
docker buildx build --platform=${BUILD_PLATFORM} -t ${DOCKER_REPO} --push .

#remove multiplatform environment
docker buildx rm ${BUIILDX_REPO}
