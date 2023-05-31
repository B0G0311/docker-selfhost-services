About
-----

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/wireguard.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/wireguard.png)                     [![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/pihole.svg.png)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/pihole.svg.png)                    [![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/unbound.svg)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/unbound.svg)

[Wireguard](#root/ieoyiAlG1oNA) is a virtual private network (VPN), it provides you a secure, encrypted tunnel for online traffic and allow you to manage a remote private network. [Pihole](#root/Z9qjfRT7EmLW) is a DNS sinkhole that protects your devices from unwanted content without installing any client-side software. [Unbound](#root/lu5dExiERKwA) is a validating, recursive, caching DNS resolver.

[Wireguard](#root/ieoyiAlG1oNA)

*   [Github](https://github.com/WireGuard)
*   [Documentation](https://www.wireguard.com/quickstart/)
*   [Docker Image](https://hub.docker.com/r/linuxserver/wireguard)

[Pi-Hole](#root/Z9qjfRT7EmLW)

*   [Github](https://github.com/pi-hole/pi-hole)
*   [Documentation](https://docs.pi-hole.net/)
*   [Docker Image](https://hub.docker.com/r/pihole/pihole)

[Unbound](#root/lu5dExiERKwA)

*   [Github](https://github.com/NLnetLabs/unbound)
*   [Documentation](https://unbound.docs.nlnetlabs.nl/en/latest/)
*   [Docker Image](https://hub.docker.com/r/mvance/unbound)

This guide combine the three services so that every device that are connected to the VPN also pass through [pihole](#root/Z9qjfRT7EmLW) and [unbound](#root/lu5dExiERKwA). Having a VPN will also reinforce security for your overall infrastructure as you can combine it with traefik IP whitelist.

Credits to [@IAmStoxe](https://github.com/IAmStoxe/wirehole).

Files structure
---------------

```text-plain
.
|-- docker-compose.yml
|-- etc-dnsmasq.d/
|-- etc-pihole/
|-- unbound/
`-- wireguard/
```

*   `docker-compose.yml` - a docker-compose file, use to configure your application’s services
*   `etc-dnsmasq.d/` - a directory used to store dnsmasq configs
*   `etc-pihole/` - a directory used to store your Pi-hole configs
*   `wireguard/` - a directory used to store wireguard data, including client ready-to-use configuration files
*   `unbound/` - a directory used to store unbound data

Please make sure that all the files and directories are present.

Information
-----------

### docker-compose

Links to the following docker-compose.yml and the corresponding .env.

*   docker-compose.yml

```text-plain
 version: "3"

services:
  unbound:
    image: klutchell/unbound:latest
    container_name: unbound
    restart: unless-stopped
    hostname: unbound
	volumes:
	  - ./unbound:/etc/unbound/custom.conf.d
    networks:
      private_network:
        ipv4_address: 10.2.0.200
    healthcheck:
      test: ["CMD", "dig", "-p", "53", "dnssec.works", "@127.0.0.1"]
      interval: 30s
      timeout: 30s
      retries: 3
      start_period: 30s
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"


  pihole:
    depends_on: [unbound]
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    hostname: pihole
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    dns:
      - 127.0.0.1
      - 10.2.0.200 # Points to unbound
    environment:
      TZ: ${TZ}
      WEBPASSWORD: ${WEBPASSWORD} # Blank password - Can be whatever you want.
      ServerIP: 10.1.0.100 # Internal IP of pihole
      DNS1: 10.2.0.200 # Unbound IP
      DNS2: 10.2.0.200 # If we don't specify two, it will auto pick google.
    # Volumes store your data between container upgrades
    volumes:
      - "./pihole/etc-pihole/:/etc/pihole/"
      - "./pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/"
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    cap_add:
      - NET_ADMIN
    networks:
      proxy: 
      private_network:
        ipv4_address: 10.2.0.100
     
    labels:
      - "traefik.enable=true"
      #- "traefik.http.routers.pihole.service: pihole"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.pihole.rule=Host(`pihole.bogoscorner.tech`)"
      - "traefik.http.routers.pihole.entrypoints=https"
      - "traefik.http.routers.pihole.tls=true"
      - "traefik.http.routers.pihole.tls.certresolver=mydnschallenge"
      - "traefik.http.middlewares.pihole-admin.addprefix.prefix: /admin/"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.monitor-only=true"
      # Ip filtering
      - "traefik.http.routers.pihole.middlewares=whitelist@file"
      
  
  wireguard:
    depends_on: [unbound, pihole]
    image: linuxserver/wireguard
    container_name: wireguard
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID={$PUID}
      - PGID={$PGID}
      - TZ={$TZ}
      - SERVERURL={$SERVERURL}
      - PEERS={$PEERS}
    volumes:
      - ./wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - "51820:51820/udp"
    dns:
      - 10.2.0.100 # Points to pihole
      - 10.2.0.200 # Points to unbound
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    networks:
      proxy:
      private_network:
        ipv4_address: 10.2.0.150
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=proxy"
      - "traefik.http.routers.wireguard.rule=Host(`vpn.bogoscorner.tech`)"
      - "traefik.http.routers.wireguard.entrypoints=https"
      - "traefik.http.routers.wireguard.tls=true"
      - "traefik.http.routers.wireguard.tls.certresolver=mydnschallenge"
      - "traefik.http.services.wireguard.loadbalancer.server.port=51820"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
      # Ip filtering
      - "traefik.http.routers.wireguard.middlewares=whitelist@file"

networks:
  proxy:
    external: true
  private_network:
    ipam:
      driver: default
      config:
        - subnet: 10.2.0.0/24
```

*   .env

```text-plain
SERVERURL=
WEBPASSWORD=
TZ=
# How many peers to generate for you (clients)
PEERS=2

# user PUID and group PGID - can be found by running id your-user
PUID=
PGID=
```

Usage
-----

### Requirements

*   A subdomain of your choice for your VPN, this example uses `vpn`.
    *   You should be able to create a subdomain with your DNS provider, use a `CNAME record` with the same IP address as your root domain.
*   Ports 51820 open, check your firewall.

### Configuration

The linuxserver images are using the PUID and PGID, they allow the container to map the container's internal user to a user on the host machine, more information [here](https://docs.linuxserver.io/general/understanding-puid-and-pgid).

To find yours, use `id user`. Replace the environment variables in `.env` with your own, then run :

```text-plain
sudo docker-compose up -d
```

#### Wireguard

*   Getting the client configuration file

You should be able to find the required configuration for your clients in the `wireguard` directory. Each client will have an associated folder called `peerX`. Inside this folder you can find a QR code for your smartphone as well as configuration file for your Linux/Windows.

*   Adding more clients

If you want more clients, just change the value in the `.env` file and relaunch the service `sudo docker-compose up -d`.

#### Pihole

Once connected to the VPN you should be able to access the pihole admin interface at [http://10.2.0.100/admin](http://10.2.0.100/admin), for more information regarding pihole you can check the well written official pihole [documentation](https://docs.pi-hole.net/).

### Update

The images are automatically updated with [watchtower](#root/erRihXn8XDdG) thanks to the following label :

```text-plain
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

Security
--------

A VPN is often a good solution to always have a dedicated IP. If you want to secure your others services, you can limit their access only when you are connected to your VPN. An easy way to do that is to add the private IP address range used by docker (172.16.0.0/12), your internal IP through the VPN will be one of this range, to the [traefik](#root/7Zv8K6vdcLKg) whitelist.

Keep in mind that only the containers that have the following label attached will be prone to this IP restriction.

```text-plain
  # Ip filtering
  - "traefik.http.routers.service-router-name.middlewares=whitelist@file"
```

Backup
------

Docker volumes are globally backed up using [borg-backup](#root/Da55PSbiIxr1).