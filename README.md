# Transmission

This image is based on *Kafouche Alpine Linux Base Image*.

## Mount / Volume

| Volume                             | Description         |
|------------------------------------|---------------------|
| `/var/lib/transmission/config/`    | Config Directory.   |
| `/var/lib/transmission/downloads/` | Download Directory. |

## Network Ports

| Port        | Description                       |
|-------------|-----------------------------------|
| `9091/tcp`  | Web Interface.                    |
| `51413/tcp` | Transmission port for bittorrent. |
| `51413/udp` | Transmission port for bittorrent. |
