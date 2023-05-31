About
-----

{ ![](api/images/0Tj6QIGEzAqW/iu.jpg)

[Heimdall](#root/bRsz36z9xc2x) is an elegant, yet simple static dashboard.  It's provides a quick tab solution for all your web applications or… any link you might like.

*   [Github](https://github.com/linuxserver/Heimdall)
*   [Documentation](https://github.com/linuxserver/Heimdall/wiki)
*   [Docker Image](https://hub.docker.com/r/linuxserver/heimdall/)

File Structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
`-- config/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `config/` - a directory containing the configuration files for Heimdall

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "3"

services:
  heimdall:
    image: lscr.io/linuxserver/heimdall:latest
    container_name: heimdall
    restart: unless-stopped
    network:
      - proxy
    volumes:
      -./config:/config
    environment:
      - PUID= ${PUID}
      - PGID= ${PGID}
      - TZ= ${America/New_York}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.heimdall.entrypoints=https"
      - "traefik.http.routers.heimdall.middlewares=whitelist@file"
      - "traefik.http.routers.heimdall.rule=Host(`${TRAEFIK_HEIMDALL}`)"
      - "traefik.http.routers.heimdall.tls=true"
      - "traefik.http.routers.heimdall.tls.certresolver=mydnschallenge"
      - "traefik.http.services.heimdall.loadbalancer.server.port=80"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      # Ip filtering
      #- "traefik.http.routers.bitwarden.middlewares=whitelist@file"
 networks:
   proxy:
     external:true
```

*   .env

```text-plain
PUID=
PGID=
TZ=
TRAEFIK_HEIMDALL=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `dash`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

[Traefik](#root/7Zv8K6vdcLKg) enabled IP whitelisting

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).