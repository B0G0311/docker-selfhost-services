About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/jellyfin.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/jellyfin.png)

This stack uses Jellyfin to manage your media library implementing a media player and ebook reader as well as many other features. Jellyseerr is a request management service that works along with the services in the organizarr-stack to pull the correct files.

[Jellyfin](#root/80USfCAGrCMG)

*   Github
*   Documentation
*   Docker Image

[Jellyseerr](#root/XjAjOfcwuU0i)

*   Github
*   Documentation
*   Docker Image

File Structure
--------------

```text-plain
.
|-- docker-compose.yml
|-- .env
|-- jellyfin/
`-- jellyseerr/

~/media/
  |-- anime
  |-- books
  |-- movies
  |-- music
  `-- tvshows
```

*   `anime` - The media directory containing anime files
*   `books` - The media directory containing book files and PDF's
*   `movies` - The media directory containing movies
*   `music` - The media directory containing music
*   `tvshows` - The media directory containing TV shows
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `.env` - a file containing all the environment variables used in the docker-compose.yml

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "2.1" 

services: 
  jellyfin: 
    image: linuxserver/jellyfin 
    container_name: jellyfin 
    networks: 
      - proxy 
    environment: 
      - PUID={$PUID}
      - PGID={$PGID}
      - TZ={$TZ} 
    volumes: 
      - ./jellyfin:/config 
      - /path/to/media/tvshows:/data/tvshows 
      - /path/to/media/movies:/data/movies 
      - /path/to/media/anime:/data/anime 
      - /path/to/media/books:/data/books 
      - /path/to/media/music:/data/music 
      - /path/to/media/pictures:/data/pictures 
    ports: 
      - 8096:8096 
    labels: 
      - "traefik.enable=true" 
      - "traefik.http.routers.jellyfin.rule=Host(`${TRAEFIK_JELLYFIN}`)" 
      - "traefik.http.routers.jellyfin.entrypoints=https" 
      - "traefik.http.routers.jellyfin.tls=true" 
      - "traefik.http.routers.jellyfin.tls.certresolver=mydnschallenge" 
      # Watchtower Update 
      - "com.centurylinklabs.watchtower.enable=true" 
      # Ip filtering 
      - "traefik.http.routers.jellyfin.middlewares=whitelist@file" 
    restart: unless-stopped 
  
  jellyseerr: 
    image: fallenbagel/jellyseerr:develop 
    container_name: jellyseerr 
    networks: 
      - proxy 
    environment: 
      - LOG_LEVEL={$LOG_LEVEL} 
      - TZ={$TZ} 
    ports: 
      - 5055:5055 
    volumes: 
      - ./jellyseerr:/app/config 
    labels: 
      - "traefik.enable=true" 
      - "traefik.http.routers.jellyseerr.rule=Host(`${TRAEFIK_JELLYSEERR}`)" 
      - "traefik.http.routers.jellyseerr.entrypoints=https" 
      - "traefik.http.routers.jellyseerr.tls=true" 
      - "traefik.http.routers.jellyseerr.tls.certresolver=mydnschallenge" 
      # Watchtower Update 
      - "com.centurylinklabs.watchtower.enable=true" 
      # Ip filtering 
      - "traefik.http.routers.jellyseerr.middlewares=whitelist@file" 
    restart: unless-stopped 
      
  networks: 
    proxy: 
      external: true
```

*   .env

```text-plain
TRAEFIK_JELLYFIN=
TRAEFIK_JELLYSEERR=
PUID=
PGID=
TZ=
LOG_LEVEL=debug
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running
*   A subdomain of your choice, this example uses `jellyfin` and `jellyseerr`
    *   You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should then be able to access the [Jellyfin](#root/80USfCAGrCMG) and [Jellyseerr](#root/XjAjOfcwuU0i) web-UI.

#### Note

[Jellyfin](#root/80USfCAGrCMG) can be combined with [Qbitorrent](#root/Ta5BTFNWjGyL), download any media you want and watch them directly on [Jellyfin](#root/80USfCAGrCMG)! In order to do that, you can configure a volume on [Qbitorrent](#root/Ta5BTFNWjGyL) that will link to the volume in [Jellyfin](#root/80USfCAGrCMG) or the opposite.

In  [Qbitorrent](#root/Ta5BTFNWjGyL), you could replace

```text-plain
  - ./data/downloads:/downloads
```

With :

```text-plain
  - ../jellyfin/media:/downloads
```

This can be configured more precisely, depending on your use-case.

### Update

The images are automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

System wide with [fail2ban](#root/rH6XoBOOOwjp).

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).

You may want to exclude the cache and media folder from the backups, add the following to [`borg-backup/excludes.txt`](#root/q9ZDiG1wZZnl):

```text-plain
/full/path/to/jellyfin/cache
/full/path/to/jellyfin/media
```