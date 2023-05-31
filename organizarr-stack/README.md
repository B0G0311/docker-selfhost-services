About
-----

![Sonarr | WikiArr](api/images/525BVY6RlaYf/iu.png)

This stack of \*Arr services is used to request and organize metadata that is downloaded from a Torrent or Usenet service. This stack will help with media from TV shows, movies and, books, as well as provide subtitles for media.

[Sonarr](#root/qXCEoP7JDPzq)

*   [Github](https://github.com/Sonarr/Sonarr)
*   [Documentation](https://wiki.servarr.com/sonarr)
*   [Docker Image](https://hub.docker.com/r/linuxserver/sonarr/)

[Radarr](https://github.com/Radarr/Radarr)

*   [Github](https://github.com/Radarr/Radarr)
*   [Documentation](https://wiki.servarr.com/radarr)
*   [Docker Image](https://hub.docker.com/r/linuxserver/radarr)

[Readarr](#root/Zw4hWTgXApSo)

*   [Github](https://github.com/Readarr/Readarr)
*   [Documentation](https://wiki.servarr.com/readarr)
*   [Docker Image](https://hub.docker.com/r/linuxserver/readarr)

[Bazarr](#root/qkwTiL9UbACa)

*   [Github](https://github.com/morpheus65535/bazarr)
*   [Documentation](https://wiki.bazarr.media/)
*   [Docker Image](https://hub.docker.com/r/linuxserver/bazarr/)

File Structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
|-- sonarr/
|-- radarr/
|-- readarr/
`--bazarr/

~/media/
  |--anime/
  |--books/
  |--movies/
  |--music/
  |--tvshows/
  

~/docker/qbittorrent/
  |--downloads/
  	|--complete/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `sonarr` - a config directory for Sonarr
*   `radarr` - a config directory for Radarr
*   `readarr` - a config directory for Readarr
*   `bazarr` - a config directory for Bazarr
*   `media/anime`\- a media directory containing anime 
*   `media/books`\- a media directory containing books
*   `media/movies`\- a media directory containing movies
*   `media/music`\- a media directory containing music
*   `media/tvshows`\- a media directory containing TV shows
*   `docker/qbittorrent/downloads/complete`\- a directory containing the completed downloads from Qbittorrent

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "2.1" 

services: 
   sonarr: 
     image: linuxserver/sonarr 
     container_name: sonarr 
     networks: 
       - proxy 
     environment: 
       - PUID=${PUID}
       - PGID=${PGID} 
       - TZ={$TZ} 
     volumes: 
       - ./sonarr:/config 
       - /path/to/media/anime:/anime 
       - /path/to/media/tvshows:/tvshows 
       - /path/to/qbittorrent/downloads/complete:/downloads/complete 
     ports: 
       - 8989:8989 
     labels: 
       - "traefik.enable=true" 
       - "traefik.http.routers.sonarr.rule=Host(`${TRAEFIK_SONARR}`)" 
       - "traefik.http.routers.sonarr.entrypoints=https" 
       - "traefik.http.routers.sonarr.tls=true" 
       - "traefik.http.routers.sonarr.tls.certresolver=mydnschallenge" 
       # Watchtower Update 
       - "com.centurylinklabs.watchtower.enable=true" 
       # Ip filtering 
       - "traefik.http.routers.sonarr.middlewares=whitelist@file" 
     restart: unless-stopped 
     
     
   radarr: 
     image: linuxserver/radarr 
     container_name: radarr 
     networks: 
       - proxy 
     environment: 
       - PUID=${PUID}
       - PGID=${PGID} 
       - TZ={$TZ} 
     volumes: 
       - ./radarr:/config 
       - /path/to/qbittorrent/downloads/complete:/downloads/complete 
       - /path/to/media/movies:/movies 
     ports: 
       - 7678:7878 
     labels: 
       - "traefik.enable=true" 
       - "traefik.http.routers.radarr.rule=Host(`${TRAEFIK_RADARR}`)" 
       - "traefik.http.routers.radarr.entrypoints=https" 
       - "traefik.http.routers.radarr.tls=true" 
       - "traefik.http.routers.radarr.tls.certresolver=mydnschallenge" 
       # Watchtower Update 
       - "com.centurylinklabs.watchtower.enable=true" 
       # Ip filtering 
       - "traefik.http.routers.radarr.middlewares=whitelist@file" 
     restart: unless-stopped 
   
   
   readarr: 
     image: linuxserver/readarr:nightly 
     container_name: readarr 
     networks: 
       - proxy 
     environment: 
       - PUID=${PUID}
       - PGID=${PGID}
       - TZ={$TZ} 
     volumes: 
       - ./readarr:/config 
       - /path/to/qbittorrent/downloads/complete:/downloads/complete 
       - /path/to/media/books:/books 
     ports: 
       - 8787:8787 
     labels: 
       - "traefik.enable=true" 
       - "traefik.docker.network=proxy" 
       - "traefik.http.routers.readarr.rule=Host(`${TRAEFIK_READARR}`)" 
       - "traefik.http.routers.readarr.entrypoints=https" 
       - "traefik.http.routers.readarr.tls=true" 
       - "traefik.http.routers.readarr.tls.certresolver=mydnschallenge" 
       - "traefik.http.services.readarr.loadbalancer.server.port=8787" 
       # Watchtower Update 
       - "com.centurylinklabs.watchtower.enable=true" 
       # Ip filtering 
       - "traefik.http.routers.readarr.middlewares=whitelist@file" 
       
       
   bazarr: 
     image: linuxserver/bazarr 
     container_name: bazarr 
     networks: 
       - proxy 
     environment: 
       - PUID=${PUID} 
       - PGID=${PGID} 
       - TZ=${TZ} 
     volumes: 
       - ./bazarr:/config 
       - /path/to/media/movies:/movies #optional 
       - /path/to/media/tvshows:/tvshows #optional 
       - /path/to/media/anime:/anime 
     ports: 
       - 6767:6767 
     labels: 
       - "traefik.enable=true" 
       - "traefik.docker.network=proxy" 
       - "traefik.http.routers.bazarr.rule=Host(`${TRAEFIK_BAZARR}`)" 
       - "traefik.http.routers.bazarr.entrypoints=https" 
       - "traefik.http.routers.bazarr.tls=true" 
       - "traefik.http.routers.bazarr.tls.certresolver=mydnschallenge"  
       # Watchtower Update 
       - "com.centurylinklabs.watchtower.enable=true" 
       # Ip filtering 
       - "traefik.http.routers.bazarr.middlewares=whitelist@file" 
     restart: unless-stopped 
     
     
 networks: 
   proxy: 
     external: true
```

*   .env

```text-plain
TRAEFIK_SONARR=
TRAEFIK_RADARR=
TRAEFIK_READARR=
TRAEFIK_BAZARR=

PUID=1000
PGID=1000
TZ=America/New_York
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `sonarr`, `radarr`, `readarr`, `bazarr`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

Access each of the web-UI's and configure basic settings, such as:

*   Download Clients

### Update

The images are automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

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

You may want to exclude the media folder from the backups, add the following to [`borg-backup/excludes.txt`](#root/q9ZDiG1wZZnl):

```text-plain
/full/path/to/media
```