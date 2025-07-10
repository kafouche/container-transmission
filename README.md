# Transmission

This image is based on *Kafouche Alpine Linux*.

## Mount / Volume

| Volume                             | Description         |
|------------------------------------|---------------------|
| `/var/lib/transmission/config/`    | Config Directory.   |
| `/var/lib/transmission/downloads/` | Download Directory. |

## Network Ports

| Port        | Description                                  |
|-------------|----------------------------------------------|
| `9091/tcp`  | Web Interface.                               |
| `51413/tcp` | (Optional) Transmission port for bittorrent. |
| `51413/udp` | (Optional) Transmission port for bittorrent. |
