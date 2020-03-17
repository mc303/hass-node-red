#!/bin/sh
env DOCKER_BUILDKIT=1 docker build --no-cache -t mc303/hass-node-red .

#create platform buildx env
# docker buildx create --platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 --name buildhassnodered
# docker buildx use buildhassnodered

# # build platforms
# docker buildx build --platform=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 -t mc303/hass-node-red --push .

# # remove build env
# docker buildx rm buildhassnodered