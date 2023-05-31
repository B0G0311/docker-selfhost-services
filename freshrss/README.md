About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/freshrss.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/freshrss.png)

FreshRSS is a self-hosted RSS feed aggregator

*   [Github](https://github.com/FreshRSS/FreshRSS)
*   [Documentation](https://freshrss.github.io/FreshRSS/en/admins/01_Index.html)
*   [Docker Image](https://hub.docker.com/r/linuxserver/freshrss)

File Structure
--------------

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

docker-compose
--------------

Links to the following [docker-compose.yml](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/freshrss/docker-compose.yml) and the corresponding [.env](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/freshrss/.env).

*   docker-compose.yml

```text-plain
version: '3'

services:
freshrss:
    image: 'freshrss/freshrss'
    container_name: freshrss
    restart: unless-stopped
    volumes:
      - "./data:/var/www/FreshRSS/data"
    environment:
      - 'CRON_MIN=4,34'
      - TZ=${TZ}
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.webserver.rule=Host(`${TRAEFIK_FRESHRSS}`)"
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
TRAEFIK_FRESHRSS=
TZ=
```

The docker-compose contains only one service using the freshrss image.

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `freshrss`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should now be able to access the freshrss setup instruction, it is quite straight forward and nothing is required.

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).