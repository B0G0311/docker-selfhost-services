About
-----

[![](https://github.com/kovidgoyal/calibre/raw/master/resources/images/lt.png)](https://calibre-ebook.com/)

Calibre is a powerful and easy to use e-book manager. Users say it's outstanding and a must-have. It'll allow you to do nearly everything and it takes things a step beyond normal e-book software. It's also completely free and open source and great for both casual users and computer experts.

*   [Github](https://github.com/linuxserver/docker-calibre)
*   [Documentation](https://manual.calibre-ebook.com/)
*   [Docker Image](https://hub.docker.com/r/linuxserver/calibre)

File Structure
--------------

```text-plain
.
|-- .env
|-- docker-compose.yml
`-- config/

~/media/
  |-- books
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `config/` - a directory housing all of the config files for Calibre
*   `media/books/` - a directory housing all of the book files

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

*   docker-compose.yml

```text-plain
version: "3"

services:
  calibre:
    image: lscr.io/linuxserver/calibre
    container_name: calibre
    restart: unless-stopped
    ports:
      - 1069:8080
    volumes:
      - ./config
      - /path/to/media/books: /imports
    environment:
      - PGID=${PGID}
      - PUID=${PUID}
      - TZ=${TZ}
     networks:
       - proxy
     labels:
       - "traefik.enable=true"  
	   - "traefik.http.services.calibre.loadbalancer.server.port=8081" 
	   - "traefik.docker.network=proxy" 
	   - "traefik.http.routers.calibre.rule=Host(`${TRAEFIK_CALIBRE}`)" 
	   - "traefik.http.routers.calibre.entrypoints=https" 
	   - "traefik.http.routers.calibre.tls=true" 
	   - "traefik.http.routers.calibre.tls.certresolver=mydnschallenge"  
	   # Watchtower Update 
	   - "com.centurylinklabs.watchtower.enable=true" 
	   # Ip filtering 
	   - "traefik.http.routers.calibre.middlewares=whitelist@file"
      
 networks:
   proxy:
     external:true
```

*   .env

```text-plain
TRAEFIK_CALIBRE=
PGID=
PUID=
TZ=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `books`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variable in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should now be able to access the Calibre server-UI from [http://localhost:1069](https://localhost:1069) to setup.  After setup you can access the web-UI through the subdomain you set with [Traefik](#root/7Zv8K6vdcLKg).

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

You may want to exclude the media folder from the backups, add the following to [`borg-backup/excludes.txt`](#root/q9ZDiG1wZZnl):

```text-plain
/full/path/to/media
```