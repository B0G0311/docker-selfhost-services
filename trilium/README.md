About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/trilium.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/trilium.png)

Trilium Notes is a hierarchical note-taking application with focus on building large personal knowledge bases

*   [Github](https://github.com/zadam/trilium)
*   [Documentation](https://github.com/zadam/trilium/wiki/)
*   [Docker Image](https://hub.docker.com/r/zadam/trilium)

Table of Contents
-----------------

```text-plain
.
|-- .env
|-- data/
`-- docker-compose.yml
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `data/` - a directory used to store the data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

Links to the following docker-compose.yml and the corresponding .env.

*   docker-compose.yml

```text-plain
version: '3'

services:
 trilium:
    image: 'zadam/trilium:latest'
    container_name: trilium
    restart: unless-stopped
    volumes:
      - "./data:/home/node/trilium-data"
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.webserver.rule=Host(`${TRAEFIK_TRILIUM}`)"
      - "traefik.http.routers.webserver.entrypoints=https"
      - "traefik.http.routers.webserver.tls=true"
      - "traefik.http.routers.webserver.tls.certresolver=mydnschallenge"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      # Ip filtering
      #- "traefik.http.routers.bitwarden.middlewares=whitelist@file"

networks:
  proxy:
    external: true
```

*   .env

```text-plain
TRAEFIK_TRILIUM=
```

The docker-compose contains only one service using the trilium image.

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `trilium`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should then be able to access the trilium web-UI and start creating notes !

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).