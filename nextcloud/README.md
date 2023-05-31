About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/nextcloud.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/nextcloud.png)

Nextcloud is a safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

*   [Github](https://github.com/nextcloud/docker)
*   [Documentation](https://docs.nextcloud.com/server/latest/admin_manual/contents.html)
*   [Docker Image](https://hub.docker.com/_/nextcloud)

Files structure
---------------

```text-plain
.
|-- .env
|-- docker-compose.yml
|-- cron/
|-- database/
|-- redis/
`-- shared/
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `database/` - a directory used to store the mariadb data
*   `redis/`\- a directory containing the current cache data
*   `shared/` - a directory used to store nextcloud's data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

Links to the following docker-compose.yml and the corresponding [.](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/nextcloud/.env)env.

*   docker-compose.yml

```text-plain
version: '3'

services:
  nextcloud-db:
    image: mariadb
    container_name: nextcloud-db
    hostname: nextcloud-db
    command: --transaction-isolation=READ-COMMITTED --innodb_read_only_compressed=OFF
    restart: unless-stopped
    volumes:
      - ./database:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWD}  # Requested, set the root's password of MySQL service.
      - MYSQL_PASSWORD=${DB_PASSWD}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_LOG_CONSOLE=true
      - MYSQL_INITDB_SKIP_TZINFO=1
      - MARIADB_AUTO_UPGRADE=1
    networks:
      - nextcloud-net
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      
  nextcloud-redis:
    image: redis
    container_name: nextcloud-redis
    hostname: nextcloud-redis
    restart: unless-stopped
    volumes:
      - ./redis:/data
    networks:
      - nextcloud-net
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

  nextcloud:
    image: nextcloud
    container_name: nextcloud
    hostname: nextcloud
    user: 1000:1000
    restart: unless-stopped
    depends_on:
      - nextcloud-db
      - nextcloud-redis
    environment:
      TRUSTED_PROXIES: localhost 192.168.0.0./24 172.0.0.0/24 127.0.0.0/24
      OVERWRITEPROTOCOL: https
      OVERWRITECLIURL: https://${TRAEFIK_NEXTCLOUD}
      OVERWRITEHOST: ${TRAEFIK_NEXTCLOUD}
      REDIS_HOST: nextcloud-redis

    volumes:
      - ./shared/app/data:/var/www/html/data
      - ./shared/app:/var/www/html
    networks:
      - proxy
      - nextcloud-net
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.nextcloud.rule=Host(`${TRAEFIK_NEXTCLOUD}`)"
      - "traefik.http.routers.nextcloud.entrypoints=https"
      - "traefik.http.routers.nextcloud.tls=true"
      - "traefik.http.routers.nextcloud.tls.certresolver=mydnschallenge"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      # Ip filtering
      #- "traefik.http.routers.nextcloud.middlewares=whitelist@file"
      
  nextcloud-cron:
    image: nextcloud:apache
    container_name: nextcloud-cron
    restart: always
    volumes:
      - ./shared/app:/var/www/html
      - ./cron:/var/spool/cron/crontabs/
    networks:
      - nextcloud-net
    entrypoint: /cron.sh
    depends_on:
      - nextcloud-db
      - nextcloud-redis 
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

networks:
  nextcloud-net:
  proxy:
    external: true
```

*   .env

```text-plain
TRAEFIK_NEXTCLOUD=
DB_ROOT_PASSWD=
DB_PASSWD=
REDIS_PASSWORD=
```

Usage
-----

### Requirements

*   [Traefik](#root/7Zv8K6vdcLKg) up and running.
*   A subdomain of your choice, this example uses `cloud`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.

### Configuration

Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

You should now be able to access the nextcloud admin account creation. [Nextcloud](#root/xWLyXCBnCw74) will ask you to create your admin account as well as to choose what type of database your want to use. In the docker-compose we set up a [mariadb database](#root/wUNxVaNKMoes), choose it and enter the following database credentials.

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/nextcloud_instruction.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/nextcloud_instruction.png)

The password is the one you have modified in the `.env` file : DB\_PASSWD. [Nextcloud](#root/xWLyXCBnCw74) will now finish installing and will soon be ready to use.

### Update

The image is automatically updated with [watchtower](#root/cQeTAlsA9rc1/t1XGmtx1tE2J/loWddkjmY24U) thanks to the following label :

```text-plain
  # Watchtower Update  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

[Nextcloud](#root/xWLyXCBnCw74) provides client-side end-to-end data encryption. You can create encrypted libraries to use this feature. Use this feature to add extra security to your documents.

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).