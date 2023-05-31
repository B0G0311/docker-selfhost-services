About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/bitwarden.svg.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/bitwarden.svg.png)

[Vaultwarden](#root/qCtO893VeGHe) is an alternative implementation of the Bitwarden server API written in Rust and compatible with upstream Bitwarden clients, it is perfect for self-hosted deployment where running the official resource-heavy service might not be ideal.

*   [Github](https://github.com/dani-garcia/vaultwarden)
*   [Documentation](https://github.com/dani-garcia/vaultwarden/wiki)
*   [Docker Image](https://hub.docker.com/r/vaultwarden/server)

Bitwarden is a free and open-source password management service that stores sensitive information such as website credentials in an encrypted vault.

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
*   `data/` - a directory used to store vaultwarden data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

Links to the following docker-compose.yml and the corresponding .env.

*   docker-compose.yml

```text-plain
version: "3"

services:
  vaultwarden:
    image: vaultwarden/server
    container_name: vaultwarden
    restart: unless-stopped
    volumes:
      - ./vw-data:/data
    environment:
      - WEBSOCKET_ENABLED=true
      - WEB_VAULT_ENABLED=true
      - SIGNUPS_ALLOWED=false
      
      # Comment admin token to disable admin interface
      - ADMIN_TOKEN=${ADMIN_TOKEN}
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.bitwarden.rule=Host(`${TRAEFIK_VAULTWARDEN}`)"
      - "traefik.http.routers.bitwarden.entrypoints=https"
      - "traefik.http.routers.bitwarden.tls=true"
      - "traefik.http.routers.bitwarden.tls.certresolver=mydnschallenge"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      # Ip filtering
      #- "traefik.http.routers.bitwarden.middlewares=whitelist@file"
    logging:
      driver: "syslog"
      options:
        tag: "Bitwarden"

networks:
  proxy:
    external: true
```

*   .env

```text-plain
TRAEFIK_VAULTWARDEN=
ADMIN_TOKEN=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `vault`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variable in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should then be able to access the bitwarden web-UI admin interface with the ADMIN\_TOKEN.

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

Comment admin token to disable the admin interface after you have created your users. 

The IP filtering label is set in the docker-compose, you can restrict access to this service by modifying the traefik whitelist.

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).