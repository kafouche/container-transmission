# Dockerfile: transmission
# Transmission Docker Image.

LABEL       org.opencontainers.image.source https://github.com/kafouche/transmission

# BUILD STAGE

FROM        ghcr.io/kafouche/alpine:latest as buildstage

ARG         RELEASE=4.0.6

RUN         apk --no-cache --update upgrade \
            && apk --no-cache --update add \
                clang \
                cmake \
                curl-dev \
                gettext-dev \
                gtest-dev \
                linux-headers \
                openssl-dev \
                patch \
                samurai

RUN         apk --no-cache --update add \
                libdeflate-dev \
                libevent-dev \
                libnatpmp-dev \
                libpsl-dev \
                miniupnpc-dev

COPY        miniupnpc.patch /tmp/

RUN         apk --no-cache --update add \
                curl \
            && curl \
                --location "https://github.com/transmission/transmission/releases/download/$RELEASE/transmission-$RELEASE.tar.xz" \
                --output /tmp/source.tar.xz \
            && mkdir --parents /tmp/source \
            && tar --directory=/tmp/source --extract \
                --file=/tmp/source.tar.xz \
                --xz --strip-components=1 \
            && patch --directory=/tmp/source/libtransmission/ < /tmp/miniupnpc.patch

WORKDIR     /tmp/source

RUN         cmake -B build -G Ninja \
                -DBUILD_SHARED_LIBS=OFF \
                -DCMAKE_BUILD_TYPE=None \
                -DCMAKE_INSTALL_PREFIX=/usr \
                -DCMAKE_INSTALL_LIBDIR=lib \
                -DENABLE_DEPRECATED=ON \
                -DENABLE_CLI=OFF \
                -DENABLE_GTK=OFF \
                -DENABLE_NLS=OFF \
                -DENABLE_QT=OFF \
                -DENABLE_TESTS=ON \
                -DUSE_SYSTEM_DEFLATE=ON \
                -DUSE_SYSTEM_EVENT2=ON \
                -DUSE_SYSTEM_MINIUPNPC=ON \
                -DUSE_SYSTEM_PSL=ON \
                -DWITH_CRYPTO="openssl" \
                -DWITH_SYSTEMD=OFF \
            && cmake --build build \
            && ctest --test-dir build --output-on-failure -j4 -E LT.DhtTest.usesBootstrapFile \
            && DESTDIR=/tmp/install/ cmake --install build

# RUN STAGE

FROM        ghcr.io/kafouche/alpine:latest

RUN         apk --no-cache --update upgrade \
            && apk --no-cache --update add \
                libcurl \
                libdeflate \
                libevent \
                libnatpmp \
                libpsl \
                libstdc++ \
                miniupnpc


RUN         adduser -D -G users -h /config -s /sbin/nologin -S transmission \
            && mkdir --parents /config/torrents /downloads

COPY        --from=buildstage /tmp/install/ /
COPY        settings.json /config/

RUN         chown -R transmission:users /config /downloads \
            && chmod 644 /config/settings.json

VOLUME      /config \
            /downloads

WORKDIR     /config

EXPOSE      9091/tcp \
            51413/tcp \
            51413/udp

USER        transmission

ENTRYPOINT  [ "/usr/bin/transmission-daemon", "--config-dir", "/config", "--foreground" ]
