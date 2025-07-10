# Dockerfile: transmission
# Kafouche Transmission Image.

LABEL       org.opencontainers.image.authors="kafouche"
LABEL       org.opencontainers.image.base.name="ghcr.io/kafouche/transmission:latest"
LABEL       org.opencontainers.image.ref.name="ghcr.io/kafouche/alpine"
LABEL       org.opencontainers.image.source="https://github.com/kafouche/docker-transmission"
LABEL       org.opencontainers.image.title="Transmission BitTorrent"


# ------------------------------------------------------------------------------

FROM        ghcr.io/kafouche/alpine:latest

RUN         apk --no-cache --update upgrade \
            && apk --no-cache --update add \
              transmission-daemon

RUN         mkdir --parents /var/lib/transmission/{config,downloads}

COPY        src/settings.json /var/lib/transmission/config/

RUN         chown -R transmission:transmission /var/lib/transmission/ \
            && chmod 644 /var/lib/transmission/config/settings.json

VOLUME      /var/lib/transmission/config/ \
            /var/lib/transmission/downloads/

WORKDIR     /var/lib/transmission/

EXPOSE      9091/tcp \
            51413/tcp \
            51413/udp

USER        transmission

ENTRYPOINT  [ \
              "/usr/bin/transmission-daemon", \
              "--config-dir", "/var/lib/transmission/config/", \
              "--download-dir", "/var/lib/transmission/downloads/", \
              "--foreground" \
            ]