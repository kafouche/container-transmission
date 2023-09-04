# Dockerfile: transmission
# Transmission Docker Image.

FROM        alpine:latest

RUN         apk upgrade --no-cache --update \
            && apk add --no-cache --update \
                transmission-daemon

EXPOSE      9091/tcp \
            51413/tcp \
            51413/udp

ENV         TZ=Europe/Paris

VOLUME      [ "/transmission" ]

ENTRYPOINT  [ "/usr/bin/transmission-daemon", "--foreground" ]
CMD         [ "--config-dir", "/transmission" ]