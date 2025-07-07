# Dockerfile: transmission
# Kafouche Transmission Image.

LABEL       org.opencontainers.image.authors="kafouche"
LABEL       org.opencontainers.image.base.name="ghcr.io/kafouche/transmission:latest"
LABEL       org.opencontainers.image.ref.name="ghcr.io/kafouche/alpine"
LABEL       org.opencontainers.image.source="https://github.com/kafouche/docker-transmission"
LABEL       org.opencontainers.image.title="Transmission BitTorrent"

FROM        ghcr.io/kafouche/alpine:latest

RUN         apk --no-cache --update upgrade \
            && apk --no-cache --update add \
              transmission-daemon

RUN         mkdir --parents /config/torrents /downloads

COPY        src/settings.json /config/

RUN         chown -R transmission:transmission /config /downloads \
            && chmod 644 /config/settings.json

VOLUME      /config \
            /downloads

WORKDIR     /config

EXPOSE      9091/tcp \
            51413/tcp \
            51413/udp

USER        transmission

ENTRYPOINT  [ "/usr/bin/transmission-daemon", "--config-dir", "/config", "--foreground" ]
