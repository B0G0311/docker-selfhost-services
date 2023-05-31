About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/gotify.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/gotify.png)

Gotify is a simple server for sending and receiving notification messages. It is used a lot throughout this guide for services such as backups and automatic updates, a must-have self-hosted solution.

*   [Github](https://github.com/gotify/server)
*   [Documentation](https://gotify.net/docs/index)
*   [Docker Image](https://hub.docker.com/r/gotify/server)

File structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
`-- data/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `data/` - a directory used to store the service's data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "3"

services:
  gotify:
    image: gotify/server
    container_name: gotify
    restart: unless-stopped
    volumes:
      - "./data:/app/data"
    environment:
      - GOTIFY_DEFAULTUSER_PASS=${GOTIFY_DEFAULTUSER_PASS}
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gotify.rule=Host(`${TRAEFIK_GOTIFY}`)"
      - "traefik.http.routers.gotify.entrypoints=https"
      - "traefik.http.routers.gotify.tls=true"
      - "traefik.http.routers.gotify.tls.certresolver=mydnschallenge"
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
TRAEFIK_GOTIFY=
GOTIFY_DEFAULTUSER_PASS=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `gotify`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should then be able to access the gotify web-UI with the default user being `admin` and the GOTIFY\_DEFAULTUSER\_PASS defined in `.env`.

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

Don't forget to change the GOTIFY\_DEFAULTUSER\_PASS after first using it.

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).