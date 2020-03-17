#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  docker buildx build \
    --progress plain \
    --platform=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u mc303 --password-stdin &> /dev/null
TAG="${TRAVIS_TAG:-latest}"
docker buildx build \
     --progress plain \
     --platform=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
     -t $DOCKER_REPO:latest \
     --push \
    .