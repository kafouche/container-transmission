# Transmission
This image is based on *Alpine Linux* latest stable image.

## Image
### Environment
| Parameter | Description                                          |
|-----------|------------------------------------------------------|
| `TZ`      | Set container's timezone (*default*: `Europe/Paris`) |

### Mount / Volume
| Volume          | Description                  |
|-----------------|------------------------------|
| `/transmission` | Default server tcp/udp port. |

### Network Ports
| Port        | Description                       |
|-------------|-----------------------------------|
| `9091/tcp`  | Web Interface.                    |
| `51413/tcp` | Transmission port for bittorrent. |
| `51413/tcp` | Transmission port for bittorrent. |

## Build
```
docker build -t kafouche/transmission:latest .
```


## Run (standalone)
The following `code blocks` are only there as **examples**.
### Manual
```
docker run --detach \
    --name transmission \
    --network bridge \
    --publish 9091:9091/tcp \
    --publish 51413:51413 \
    --restart unless-stopped \
    kafouche/transmission:latest
```

### Composer
```
---
version: "3"

services:
    transmission:
        container_name: "transmission"
        image: "kafouche/transmission:latest"
        network_mode: bridge
        ports:
          - 9091:9091/tcp
          - 51413:51413
        restart: unless-stopped
        volumes:
          - "./transmission:/transmission"
```


## Run (with VPN)
The following `code blocks` are only there as **examples**.
### Manual
```
docker run --detach \
    --cap-add=NET_ADMIN \
    --device=/dev/net/tun:/dev/net/tun \
    #--dns 9.9.9.9 \          # Optional
    #--dns 149.112.112.112 \  # Optional
    --mount type=bind,src=$(pwd)/openvpn,dst=/etc/openvpn \
    --name openvpn \
    --network bridge \
    --publish 9091:9091/tcp \
    --restart unless-stopped \
    kafouche/openvpn:latest

docker run --detach \
    --name=transmission \
    --net=container:openvpn \
    --restart=unless-stopped \
    --mount type=bind,src=$(pwd)/transmission,dst=/transmission \
    kafouche/transmission:latest
```

### Composer
```
---
version: "3"

services:
    openvpn:
        cap_add:
          - NET_ADMIN
        container_name: "openvpn"
        devices:
          - "/dev/net/tun:/dev/net/tun"
        #dns:
          #- 9.9.9.9
          #- 149.112.112.112
        image: "kafouche/openvpn:latest"
        network_mode: bridge
        ports:
          - 9091:9091/tcp
        restart: unless-stopped
        volumes:
          - "./openvpn/:/etc/openvpn/:ro"

    transmission:
        container_name: "transmission"
        depends_on:
          - openvpn
        image: "kafouche/transmission:latest"
        network_mode: "service:openvpn"
        restart: unless-stopped
        volumes:
          - "./transmission/:/transmission/"
```
