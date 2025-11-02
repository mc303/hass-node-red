ARG BUILD_FROM=alpine:3.20.0

FROM ${BUILD_FROM}

## --platform=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64
ARG TARGETPLATFORM
RUN echo "TARGETPLATFORM : $TARGETPLATFORM"


# Copy Node-RED package.json
# COPY requirements.txt /opt/
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
        g++ \
        gcc \
        libc-dev \
        linux-headers \
        make \
        py3-pip \
        python3-dev \
        tar \
    \
    && apk add --no-cache \
        libcrypto1.1 \
        libssl1.1 \
        musl-utils \
        musl \
    \
    && apk add --no-cache \
        bash \
        curl \
        jq \
        tzdata \
    \
    && apk add --no-cache \
        git \
        nodejs \
        npm \
        openssh-client \
        patch \
        python3 \
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
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-${XARCH}.tar.gz" \
        | tar zxvf - -C / \
    \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -fr \
        /root/.cache \
        /root/.npm \
        /root/.nrpmrc \
        /tmp/*


# Copy root filesystem
COPY rootfs /

# Health check
# HEALTHCHECK --start-period=10m \
#     CMD curl --fail http://127.0.0.1:46836 || exit 1

# Entrypoint & CMD
ENTRYPOINT ["/init"]

ENV NODE_PATH=/opt/node_modules:/data/node_modules \
    FLOWS=flows.json
