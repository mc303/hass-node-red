ARG BUILD_FROM=alpine:3.13.0

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
        g++=10.2.1_pre1-r3 \
        gcc=10.2.1_pre1-r3 \
        libc-dev=0.7.2-r3 \
        linux-headers=5.7.8-r0 \
        make=4.3-r0 \
        py3-pip=20.3.4-r0 \
        python3-dev=3.8.10-r0 \
        tar=1.34-r0 \
    \
    && apk add --no-cache \
        libcrypto1.1=1.1.1i-r0 \
        libssl1.1=1.1.1i-r0 \
        musl-utils=1.2.2-r0 \
        musl=1.2.2-r1 \
    \
    && apk add --no-cache \
        bash=5.1.0-r0 \
        curl=7.76.1-r0 \
        jq=1.6-r1 \
        tzdata=2021a-r0 \
    \
    && apk add --no-cache \
        git=2.30.2-r0 \
        nodejs=14.16.1-r1 \
        npm=14.16.1-r1 \
        openssh-client=8.4_p1-r3 \
        patch=2.7.6-r6 \
        python3=3.8.10-r0 \
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
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v2.1.0.2/s6-overlay-${XARCH}.tar.gz" \
        | tar zxvf - -C / \
    \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -fr \
        /tmp/*


# Copy root filesystem
COPY rootfs /

# Entrypoint & CMD
ENTRYPOINT ["/init"]

ENV NODE_PATH=/opt/node_modules:/data/node_modules \
    FLOWS=flows.json
