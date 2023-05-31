About
-----

 [![](api/images/rf5qSM12iv9k/logo.png)](https://airsonic.github.io/)

[Airsonic-advanced](#root/FV3bKyHATe05) is a free, web-based media streamer, providing ubiquitous access to your music. Use it to share your music with friends, or to listen to your own music while at work. You can stream to multiple players simultaneously, for instance to one player in your kitchen and another in your living room.is a free, web-based media streamer, providing ubiquitous access to your music. Use it to share your music with friends, or to listen to your own music while at work. You can stream to multiple players simultaneously, for instance to one player in your kitchen and another in your living room.

*   [Github](https://github.com/airsonic-advanced/airsonic-advanced)
*   [Documentation](https://airsonic.github.io/docs/)
*   [Docker Image](https://hub.docker.com/r/airsonicadvanced/airsonic-advanced)

File Structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
`-- airsonic/

~/media
  |--music/
  |--music/playlists/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `airsonic/` - the directory containing the airsonic configuration files
*   `media/music/` - a directory containing music files
*   `music/playlists/` - a directory containing playlists

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "3"

services:
  airsonic-advanced:
    image: airsonicadvanced/airsonic-advanced:latest
    container_name: airsonic-advanced
    restart: unless-stopped
    ports:
      - 4040:4040
    volumes:
      - ./data:/var/airsonic
      - /path/to/media/music: /var/music
      - /path/to/media/music/playlists: /var/playlists
      - /path/to/media/podcasts: /var/podcasts
    environment:
      - PUID= ${PUID}
      - PGID= ${PGID}
      - TZ= ${America/New_York}
     networks:
       - proxy
     labels:
       - "traefik.docker.network=proxy"
       - "traefik.enable=true"
       - "traefik.http.routers.airsonic.entrypoints=https"
       - "traefik.http.routers.airsonic.rule=Host(`${TRAEFIK_AIRSONIC}`)"
       - "traefik.http.routers.airsonic.tls=true"
       - "traefik.http.routers.airsonic.tls.certresolver=mydnschallenge"
       - "traefik.http.services.airsonic.loadbalancer.server.port=4040"
       # Watchtower Update
       - "com.centurylinklabs.watchtower.enable=true"
       # Ip filtering
       #- "traefik.http.routers.minecraft.middlewares=whitelist@file"
      
 networks:
   proxy:
     external:true
```

*   .env

```text-plain
TRAEFIK_AIRSONIC=
PUID=
PGID=
TZ=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `sonic`.
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