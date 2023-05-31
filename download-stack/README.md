About
-----

[![](api/images/9gF1P3FdUe98/prowlarr-banner.png)](https://github.com/Prowlarr/Prowlarr)

![](https://github.com/linuxserver/docker-templates/raw/master/linuxserver.io/img/qbittorrent-icon.png)

[Prowlarr](#root/sqnM2yrJ2429) is a indexer manager/proxy built on the popular arr .net/reactjs base stack to integrate with your various PVR apps. [Prowlarr](#root/sqnM2yrJ2429) supports both Torrent Trackers and Usenet Indexers.  The [Qbittorrent project](https://www.qbittorrent.org/) aims to provide an open-source software alternative to µTorrent. [Qbittorrent](#root/Ta5BTFNWjGyL) is based on the Qt toolkit and libtorrent-rasterbar library

[Prowlarr](#root/sqnM2yrJ2429)

*   [Github](https://github.com/Prowlarr/Prowlarr)
*   [Documentation](https://wiki.servarr.com/prowlarr)
*   [Docker Image](https://hub.docker.com/r/linuxserver/prowlarr)

[Qbittorrent](#root/Ta5BTFNWjGyL)

*   [Github](https://github.com/qbittorrent/qBittorrent)
*   [Documentation](https://github.com/qbittorrent/qBittorrent/wiki/)
*   [Docker Image](https://hub.docker.com/r/linuxserver/qbittorrent)

File Structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
|-- prowlarr/
`-- qbittorrent/
	|--config/
	|-- downloads/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `prowlarr/` - a directory containing config files for [Prowlarr](#root/sqnM2yrJ2429)
*   `qbittorrent/config/` - a directory containing the configuration files for [qBittorrent](#root/Ta5BTFNWjGyL)
*   `qbittorrent/downloads/` - a directory containing the download data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "3"

services:
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ./prowlarr:/config
    ports:
      - 9696:9696
    restart: unless-stopped
     networks:
       - download-net
     labels:
      
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    networks:
      - proxy
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=${WEBUI_PORT}
    volumes:
      - ./qbittorrent/config:/config
      - ./qbittorrent/downloads:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    labels:

    restart: unless-stopped
 networks:
 download-net:
   external:true
```

*   .env

```text-plain
PUID=
PGID=
TZ=
WEB_UI=8080
PROWLARR_SUB=
QBITTORRENT_SUB=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `prowl` and `qbit`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should then be able to access the [Prowlarr](#root/sqnM2yrJ2429) and [qBittorrent](#root/Ta5BTFNWjGyL) web-UI's through their perspective ports and domain names. 

Must change admin username and password after first login.

### Update

The image is automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

[Traefik](#root/7Zv8K6vdcLKg) enabled IP Whitelisting

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).

You may want to exclude the downloads folder from the backups, add the following to [`borg-backup/excludes.txt`:](#root/q9ZDiG1wZZnl)

```text-plain
/full/path/to/qbittorrent/data/downloads
```