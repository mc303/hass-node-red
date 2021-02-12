#ARG BUILD_FROM=alpine:3.11.3
ARG BUILD_FROM=alpine:3.11.3
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

## --platform=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64
ARG TARGETPLATFORM
RUN echo "TARGETPLATFORM : $TARGETPLATFORM"


# Copy Node-RED package.json
COPY requirements.txt /opt/
COPY package.json /opt/
#ADD from https://raw.githubusercontent.com/hassio-addons/addon-node-red/master/node-red/package.json
# && curl -s -o /opt/package.json https://raw.githubusercontent.com/hassio-addons/addon-node-red/master/node-red/package.json \

# Set workdir
WORKDIR /opt

# Set shell
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache --virtual .build-dependencies \
        g++=9.3.0-r0 \
        gcc=9.3.0-r0 \
        libc-dev=0.7.2-r0 \
        linux-headers=4.19.36-r0 \
        py2-pip=18.1-r0 \
        python2-dev=2.7.18-r0 \
        tar=1.32-r1 \
    \
    && apk add --no-cache \
        libcrypto1.1=1.1.1d-r3 \
        libssl1.1=1.1.1d-r3 \
        musl-utils=1.1.24-r2 \
        musl=1.1.24-r2 \
        make=4.2.1-r2 \
    \
    && apk add --no-cache \
        bash=5.0.11-r1 \
        curl=7.67.0-r0 \
        jq=1.6-r0 \
        tzdata=2020a-r0 \
    \
    && apk add --no-cache \
        git=2.24.3-r0 \
        nodejs=12.15.0-r1 \
        npm=12.15.0-r1 \
        openssh-client=8.1_p1-r0 \
        patch=2.7.6-r6 \
        paxctl=0.9-r0 \
        python2=2.7.18-r0 \
    \
    && paxctl -cm "$(command -v node)" \
    \
    && npm config set unsafe-perm true \
    \
    && pip install --no-cache-dir -r /opt/requirements.txt \
    \
    && npm install \
        --no-audit \
        --no-optional \
        --no-update-notifier \
        --only=production \
        --unsafe-perm \
    \
    && npm cache clear --force \
    \
    && echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    \ 
    && if [ "$TARGETPLATFORM" = "linux/386" ] ; then XARCH="x86" ; fi \
    && if [ "$TARGETPLATFORM" = "linux/amd64" ] ; then XARCH="amd64" ; fi \
    && if [ "$TARGETPLATFORM" = "linux/arm/v6" ] ; then XARCH="arm" ; fi \
    && if [ "$TARGETPLATFORM" = "linux/arm/v7" ] ; then XARCH="armhf" ; fi \
    && if [ "$TARGETPLATFORM" = "linux/arm64" ] ; then XARCH="aarch64" ; fi \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-$XARCH.tar.gz" \
        | tar zxvf - -C / \
    \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -fr \
        /tmp/* 

# Entrypoint & CMD
ENTRYPOINT ["/init"]

ENV NODE_PATH=/opt/node_modules:/data/node_modules \
    FLOWS=flows.json

# Copy root filesystem
COPY rootfs /
