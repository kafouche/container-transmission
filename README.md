# Transmission
This image is based on *Alpine Linux* latest stable image.

## Mount / Volume
| Volume       | Description         |
|--------------|---------------------|
| `/config`    | Config Directory.   |
| `/downloads` | Download Directory. |

## Network Ports
| Port        | Description                       |
|-------------|-----------------------------------|
| `9091/tcp`  | Web Interface.                    |
| `51413/tcp` | Transmission port for bittorrent. |
| `51413/udp` | Transmission port for bittorrent. |