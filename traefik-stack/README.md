About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/traefik.logo.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/traefik.logo.png)

[Traefik](#root/7Zv8K6vdcLKg) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. It is an Edge Router, it means that it's the door to your platform, and that it intercepts and routes every incoming request.

*   [Github](https://github.com/traefik/traefik/)
*   [Documentation](https://doc.traefik.io/traefik/)
*   [Docker Image](https://hub.docker.com/_/traefik)

[Traefik](#root/7Zv8K6vdcLKg) is a key component for this selfhosted infrastructure, it is providing the following features :

*   Act as a reverse proxy, enabling you to self-hosted multiple services behind a single IP
*   HTTPS for your services by leveraging Let's Encrypt
*   Easily configure TLS for all services
*   Use a whitelist to restrict services to a fix set of IP's

Files structure
---------------

```text-plain
. 
|-- .env 
|-- docker-compose.yml 
|-- letsencrypt/ 
|-- rules/ 
|   |-- tls.yml 
|   `-- whitelist.yml 
`-- traefik.yml
```

*   `.env` - a file containing all the environment variables used in the docker-compose.yml
*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `letsencrypt/` - a directory used to store the certificates' information
*   `rules/` - a directory used to store traefik optional rules (TLS, IP whitelist)
*   `traefik.yml` - traefik configuration file

Please make sure that all the files and directories are present.

Information
-----------

[Traefik](#root/7Zv8K6vdcLKg) has multiple ways to be configured, I will be using two of them for this guide :

*   Configuration file : Such as traefik.yml, tls.yml, ...
*   Labels : Used in a docker-compose file

The configuration could be done using only one of the two method, but I find it easy to use files for standard configurations that should almost never change and labels to allow a more dynamic configuration.

### docker-compose

Links to the following [docker-compose.yml](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/traefik/docker-compose.yml) and the corresponding [.env](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/traefik/.env).

*   docker-compose.yml

```text-plain
version: "3"

services:
  traefik:
    image: "traefik:latest"
    container_name: "traefik"
    restart: unless-stopped
    depends_on:
      - socket-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./traefik.yml:/traefik.yml:ro"
      - "./rules:/rules:ro"
      - "./letsencrypt:/letsencrypt"
    environment:
      - CF_API_EMAIL=${CF_API_EMAIL}
      - CF_API_KEY=${CF_API_KEY}
    networks:
      - proxy
    labels:
      - "traefik.enable=true"

      # global redirect to https
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=http"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"

      # middleware redirect
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.permanent=true"

      # redirect root to www
      - "traefik.http.routers.root.rule=host(`${DOMAIN}.${TLD}`)"
      - "traefik.http.routers.root.entrypoints=https"
      - "traefik.http.routers.root.middlewares=redirect-root-to-www"
      - "traefik.http.routers.root.tls=true"

      # middleware redirect root to www
      - "traefik.http.middlewares.redirect-root-to-www.redirectregex.regex=^https://${DOMAIN}\\.${TLD}/(.*)"
      - "traefik.http.middlewares.redirect-root-to-www.redirectregex.replacement=https://www.${DOMAIN}.${TLD}/$${1}"

      # Watchtower Update
      - "com.centurylinklabs.watchtower.monitor-only=true"

  socket-proxy:
    image: tecnativa/docker-socket-proxy
    container_name: traefik-socket-proxy
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      CONTAINERS: 1
    networks:
      - proxy
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.monitor-only=true"

networks:
  proxy:
    external: true
```

*   env

```text-plain
# DOMAIN.TLD = domain.tld
DOMAIN=
TLD=

# DNS challenge credentials - will not be the same if you are using another provider
CF_API_EMAIL=
CF_API_KEY=
```

The docker-compose contains two services :

*   socket-proxy : This ensures Docker’s socket file to not be exposed to the public
*   traefik : [Traefik](#root/7Zv8K6vdcLKg) application configuration

### socket-proxy

The [socket-proxy](#root/A9EcnvtBHwZ3) service is used to protect the docker socket, allowing [Traefik](#root/7Zv8K6vdcLKg) unrestricted access to your Docker socket file could result in a vulnerability to the host computer, as per [Traefik own documentation](https://doc.traefik.io/traefik/providers/docker/#docker-api-access), should any other part of the [Traefik](#root/7Zv8K6vdcLKg) container ever be compromised.

Instead of allowing [Traefik](#root/7Zv8K6vdcLKg) container full access to the Docker socket file, we can instead proxy only the API calls we need with [Tecnativa’s Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy), following the [principle of the least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

### traefik

##### DNS Challenge with Let's Encrypt

[Traefik](#root/7Zv8K6vdcLKg) can use an ACME provider (like Let's Encrypt) for automatic certificate generation. It will create the certificate and attempt to renew it automatically 30 days before expiration. One of the great benefit of using DNS challenges is that it will allow us to use wildcard certificates, on the other hand, it can create a security risk as it requires giving rights to [Traefik](#root/7Zv8K6vdcLKg) to create and remove some DNS records.

For the DNS challenge, you'll need a [working provider](https://doc.traefik.io/traefik/https/acme/#providers) along with the credentials allowing to create and remove DNS records, If you are using Cloud Flare, you can use this guide to retrieve the credentials.

##### Global redirect to HTTPS

```text-plain
      # global redirect to https
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=http"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
```

This rule will match all the HTTP requests and redirect them to HTTPS. It uses the redirect-to-https middleware.

##### Redirect root to www

```text-plain
      # redirect root to www
      - "traefik.http.routers.root.rule=host(`example.com`)"
      - "traefik.http.routers.root.entrypoints=https"
      - "traefik.http.routers.root.middlewares=redirect-root-to-www"
      - "traefik.http.routers.root.tls=true"
```

This rule will automatically redirect the root domain `example.com` to `www.example.com`. You can use the [webserver](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/webserver) example to set up a website using docker.

Usage
-----

### Requirements

*   A domain, we will use `example.com` for this guide.
*   DNS manager, usually it goes with the provider you used for your domain. We will use Cloudflare for the guide. List of compatible [providers](https://doc.traefik.io/traefik/https/acme/#providers).
*   Ports 80 and 443 open, check your firewall.

### Configuration

Before using the docker-compose file, please update the following configurations.

**change the domain** : The current domain is example.com, change it to your domain. The change need to be made in `.env` and `traefik.yml`   
 

```text-plain
  DOMAIN=example
  TLD=com
  sed -i -e "s/example/'$DOMAIN'/g" .env 
  sed -i -e "s/com/'$TLD'/g" .env
  sed -i -e "s/example.com/'$DOMAIN'.'$TLD'/g" traefik.yml 
```

**change the dns provider credentials** : Replace the provider name in `traefik.yml` if you are not using Cloudflare. Replace the environment variables in `.env` and in `docker-compose.yml`. The example uses Cloudflare but it can work with other providers, such as OVH :

*   Get the [required settings](https://go-acme.github.io/lego/dns/godaddy/) and update the `.env` file
*   This is the only case where you are going to have to modify the docker-compose

**create the docker network** : As our services are split in multiple docker-compose, we need a network so that traefik can forward the requests.   
 

```text-plain
  sudo docker network create proxy
```

**update the whitelist (optional)** : Replace the IP address in `rules/whitelist.yml`. Use the IP address as well as the [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing). Whitelist is disable by default with `0.0.0.0/0`. The whitelist will be used on containers setting the following label.   
 

```text-plain
  # Ip filtering
  - "traefik.http.routers.service-router-name.middlewares=whitelist@file"
```

You can use the private IP address range used by docker (172.16.0.0/12) if you are using [wireguard](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/wireguard-pihole-unbound). Then your services will only be available through your VPN (recommend for a better security).

You can now run :

```text-plain
sudo docker-compose up -d
```

To check the logs :

```text-plain
sudo docker logs traefik
```

Traefik should be up and running ! To test if everything is running smoothly, you can try and use the [webserver](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/webserver) service, it is a simple apache webserver showing `Hello World`. Keep in mind that traefik can take a little time to generate the first certificate, usually a couple of minutes.

#### Note

If you want to use the [Redirect root to www](https://github.com/BaptisteBdn/docker-selfhosted-apps/tree/main/traefik#redirect-root-to-www) functionality, you also need to have a certificate generated for your root domain. In order to do so, you will need to use a service which uses the root domain. The simplest way to do that is by running the [webserver](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/webserver) service with the root domain. It only needs to be done once, you should then be able to see the entry in `letsencrypt/acme.json`, it will then be renewed automatically by traefik.

### Update

Both `traefik` and `socket-proxy` images are automatically updated with [watchtower](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/watchtower) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

The socket-proxy service is used to protect the docker socket.

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).