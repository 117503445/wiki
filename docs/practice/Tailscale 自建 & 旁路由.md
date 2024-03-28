# Tailscale 自建 & 旁路由

Tailscale 是一款基于 WireGuard 协议的虚拟专用网络（VPN）工具，它可以帮助用户搭建一个安全、简单的网络，并且支持多平台使用。可以通过 Tailscale，将不同局域网的设备连接起来，实现互相访问。

## Tailscale 概述

在每个设备上安装 Tailscale 客户端，然后登录官方 Tailscale 账号后，即可加入虚拟网络。Tailscale 会为每个设备分配一个内网 IP，比如 设备1 是 `100.64.0.1`，设备2 是 `100.64.0.2` 。即使设备1和设备2处于不同的局域网，设备1 也可以通过 `100.64.0.2` 访问设备2。

Tailscale 还支持 [subnet](https://tailscale.com/kb/1019/subnets) 功能。比如设备1 的 ip 是 `192.168.1.2`, 可以向虚拟网络公布子网 `192.168.1.0/16`，然后设备 2 就可以直接访问 `192.168.1.0/16` 内的所有设备，比如 `192.168.1.3` 。这样的好处是不需要在 `192.168.1.0/16` 内的每个设备上安装 Tailscale 客户端。具体流程是 设备1 的 tailscale 传入参数 `--advertise-routes=192.168.1.0/16`，控制中心允许设备1 公布的子网后，设备2 上的 tailscale 就会改写路由表，将设备2 的 `192.168.1.0/16` 路由 指向设备2 tailscale 接口，后续流量通过设备2 的 tailscale 和 derper 转发到 `192.168.1.0/16`。这样设备2 就可以直接访问 `192.168.1.0/16` 了。

Tailscale 服务端分为控制中心和 derper。控制中心负责设备的认证、内网 IP 的分配，derper 负责设备之间的通讯。derper 是一个中继服务器，设备 1 和 设备 2 之间的流量会通过 derper 的 https 端口进行转发。同时，设备还会尝试借助 derper 的 stun 端口穿透 NAT，如果穿透成功，设备之间的流量会直接传输，不经过 derper。

Tailscale 客户端、derper 都是开源的。Tailscale 官方控制中心是不开源、高级功能收费的，也可以借助开源的 Headscale 搭建自己的控制中心。

## 方案设计

我的网络设备包含 随身的笔记本、2 个家庭网络、云服务器。我希望通过 Tailscale 将这些设备连接起来，实现互相访问。

随身的笔记本、云服务器都需要安装 tailscale 客户端。2 个家庭网络内的设备数量较多，所以我在家庭网络内只安装一个 tailscale，然后通过 subnet 的方式把整个家庭网络公布到虚拟网络中。最简单的方案是在家庭网络中的路由器 OpenWRT 上安装 tailscale 客户端，但是 OpenWRT 上的 tailscale 客户端版本较老，而且会给路由器上的 iptables 和 路由表 搞黑魔法，不易维护，所以我选择在家庭网络中的一台设备上安装 tailscale 客户端，然后手动修改 OpenWRT 的路由表。

Tailsale 官方控制中心的免费计划只支持 1 个 subnet，而我需要 2 个 subnet，所以我需要自建控制中心。我将 Headscale 部署在云服务器上。

Tailsale 官方 derper 没有大陆地区的节点，所以我需要自建 derper。我将 derper 部署在 2 个家庭网络中，因为家庭网络的上传带宽更大，且支持 IPv6。

## 部署实践

假设

- 使用泛域名表示服务器地址，都解析到相同的服务器 IP，不同 http 服务使用相同端口、不同域名，从而实现基于 host 的虚拟主机。具体见 [中小型应用运维](https://wiki.117503445.top/practice/%E4%B8%AD%E5%B0%8F%E5%9E%8B%E5%BA%94%E7%94%A8%E8%BF%90%E7%BB%B4/)
- 云服务器的域名是 `*.cloud.example.com`, https 端口 30000
- 家庭网络1的域名是 `*.homenet1.example.com`, 内网网段 `192.168.1.0/24`, 服务器 https 端口 20000，服务器内网 ip `192.168.1.2`
- 家庭网络2的域名是 `*.homenet2.example.com`, 内网网段 `192.168.2.0/24`, 服务器 https 端口 20000，服务器内网 ip `192.168.2.2`
- 家庭网络具有公网 IPv4, IPv6 地址

- 使用 Traefik 作为网关，也可以使用其他网关。

### Headscale

```yaml
# ./docker-compose.yml
services:
  headscale:
    image: headscale/headscale:v0.23.0-alpha5 # 2024.03.28
    restart: unless-stopped
    volumes:
      - ./config:/etc/headscale
      - ./data:/data
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.headscale.rule=Host(`headscale.cloud.example.com`)"
      - "traefik.http.routers.headscale.tls=true"
      - "traefik.http.services.headscale.loadbalancer.server.port=8080"
      - "traefik.http.routers.headscale.middlewares=allow-cors@file"
    command: serve
    networks:
      - traefik

  headscale-ui:
    image: ghcr.io/gurucomputing/headscale-ui
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.headscale-ui.rule=Host(`headscale-ui.cloud.example.com`)"
      - "traefik.http.routers.headscale-ui.tls=true"
      - "traefik.http.services.headscale-ui.loadbalancer.server.port=80"
      - "traefik.http.routers.headscale-ui.middlewares=basic-auth@file"
    networks:
      - traefik
networks:
  traefik:
    external: true
```

```yaml
# ./config/config.yml
# gen by wget -O ./config/config.yaml https://raw.githubusercontent.com/juanfont/headscale/main/config-example.yaml
---
# headscale will look for a configuration file named `config.yaml` (or `config.json`) in the following order:
#
# - `/etc/headscale`
# - `~/.headscale`
# - current working directory

# The url clients will connect to.
# Typically this will be a domain like:
#
# https://myheadscale.example.com:443
#
server_url: https://headscale.cloud.example.com:30000

# Address to listen to / bind to on the server
#
# For production:
# listen_addr: 0.0.0.0:8080
listen_addr: 0.0.0.0:8080

# Address to listen to /metrics, you may want
# to keep this endpoint private to your internal
# network
#
metrics_listen_addr: 0.0.0.0:9090

# Address to listen for gRPC.
# gRPC is used for controlling a headscale server
# remotely with the CLI
# Note: Remote access _only_ works if you have
# valid certificates.
#
# For production:
# grpc_listen_addr: 0.0.0.0:50443
grpc_listen_addr: 127.0.0.1:50443

# Allow the gRPC admin interface to run in INSECURE
# mode. This is not recommended as the traffic will
# be unencrypted. Only enable if you know what you
# are doing.
grpc_allow_insecure: false

# The Noise section includes specific configuration for the
# TS2021 Noise protocol
noise:
  # The Noise private key is used to encrypt the
  # traffic between headscale and Tailscale clients when
  # using the new Noise-based protocol.
  private_key_path: /data/noise_private.key

# List of IP prefixes to allocate tailaddresses from.
# Each prefix consists of either an IPv4 or IPv6 address,
# and the associated prefix length, delimited by a slash.
# It must be within IP ranges supported by the Tailscale
# client - i.e., subnets of 100.64.0.0/10 and fd7a:115c:a1e0::/48.
# See below:
# IPv6: https://github.com/tailscale/tailscale/blob/22ebb25e833264f58d7c3f534a8b166894a89536/net/tsaddr/tsaddr.go#LL81C52-L81C71
# IPv4: https://github.com/tailscale/tailscale/blob/22ebb25e833264f58d7c3f534a8b166894a89536/net/tsaddr/tsaddr.go#L33
# Any other range is NOT supported, and it will cause unexpected issues.
prefixes:
  v6: fd7a:115c:a1e0::/48
  v4: 100.64.0.0/10

# DERP is a relay system that Tailscale uses when a direct
# connection cannot be established.
# https://tailscale.com/blog/how-tailscale-works/#encrypted-tcp-relays-derp
#
# headscale needs a list of DERP servers that can be presented
# to the clients.
derp:
  server:
    # If enabled, runs the embedded DERP server and merges it into the rest of the DERP config
    # The Headscale server_url defined above MUST be using https, DERP requires TLS to be in place
    enabled: false

    # Region ID to use for the embedded DERP server.
    # The local DERP prevails if the region ID collides with other region ID coming from
    # the regular DERP config.
    region_id: 999

    # Region code and name are displayed in the Tailscale UI to identify a DERP region
    region_code: "headscale"
    region_name: "Headscale Embedded DERP"

    # Listens over UDP at the configured address for STUN connections - to help with NAT traversal.
    # When the embedded DERP server is enabled stun_listen_addr MUST be defined.
    #
    # For more details on how this works, check this great article: https://tailscale.com/blog/how-tailscale-works/
    stun_listen_addr: "0.0.0.0:3478"

    # Private key used to encrypt the traffic between headscale DERP
    # and Tailscale clients.
    # The private key file will be autogenerated if it's missing.
    #
    private_key_path: /var/lib/headscale/derp_server_private.key

    # This flag can be used, so the DERP map entry for the embedded DERP server is not written automatically,
    # it enables the creation of your very own DERP map entry using a locally available file with the parameter DERP.paths
    # If you enable the DERP server and set this to false, it is required to add the DERP server to the DERP map using DERP.paths
    automatically_add_embedded_derp_region: true

    # For better connection stability (especially when using an Exit-Node and DNS is not working),
    # it is possible to optionall add the public IPv4 and IPv6 address to the Derp-Map using:
    ipv4: 1.2.3.4
    ipv6: 2001:db8::1

#   List of externally available DERP maps encoded in JSON
  urls:
    - https://controlplane.tailscale.com/derpmap/default

  # Locally available DERP map files encoded in YAML
  #
  # This option is mostly interesting for people hosting
  # their own DERP servers:
  # https://tailscale.com/kb/1118/custom-derp-servers/
  #
  # paths:
  #   - /etc/headscale/derp-example.yaml
  # paths:
  #   - /etc/headscale/derp.yaml

  # If enabled, a worker will be set up to periodically
  # refresh the given sources and update the derpmap
  # will be set up.
  auto_update_enabled: true

  # How often should we check for DERP updates?
  update_frequency: 24h

# Disables the automatic check for headscale updates on startup
disable_check_updates: false

# Time before an inactive ephemeral node is deleted?
ephemeral_node_inactivity_timeout: 30m

# Period to check for node updates within the tailnet. A value too low will severely affect
# CPU consumption of Headscale. A value too high (over 60s) will cause problems
# for the nodes, as they won't get updates or keep alive messages frequently enough.
# In case of doubts, do not touch the default 10s.
node_update_check_interval: 10s

database:
  type: sqlite

  # SQLite config
  sqlite:
    path: /data/db.sqlite

  # # Postgres config
  # postgres:
  #   # If using a Unix socket to connect to Postgres, set the socket path in the 'host' field and leave 'port' blank.
  #   host: localhost
  #   port: 5432
  #   name: headscale
  #   user: foo
  #   pass: bar
  #   max_open_conns: 10
  #   max_idle_conns: 10
  #   conn_max_idle_time_secs: 3600

  #   # If other 'sslmode' is required instead of 'require(true)' and 'disabled(false)', set the 'sslmode' you need
  #   # in the 'ssl' field. Refers to https://www.postgresql.org/docs/current/libpq-ssl.html Table 34.1.
  #   ssl: false

### TLS configuration
#
## Let's encrypt / ACME
#
# headscale supports automatically requesting and setting up
# TLS for a domain with Let's Encrypt.
#
# URL to ACME directory
acme_url: https://acme-v02.api.letsencrypt.org/directory

# Email to register with ACME provider
acme_email: ""

# Domain name to request a TLS certificate for:
tls_letsencrypt_hostname: ""

# Path to store certificates and metadata needed by
# letsencrypt
# For production:
tls_letsencrypt_cache_dir: /var/lib/headscale/cache

# Type of ACME challenge to use, currently supported types:
# HTTP-01 or TLS-ALPN-01
# See [docs/tls.md](docs/tls.md) for more information
tls_letsencrypt_challenge_type: HTTP-01
# When HTTP-01 challenge is chosen, letsencrypt must set up a
# verification endpoint, and it will be listening on:
# :http = port 80
tls_letsencrypt_listen: ":http"

## Use already defined certificates:
tls_cert_path: ""
tls_key_path: ""

log:
  # Output formatting for logs: text or json
  format: text
  level: info

# Path to a file containg ACL policies.
# ACLs can be defined as YAML or HUJSON.
# https://tailscale.com/kb/1018/acls/
acl_policy_path: ""

## DNS
#
# headscale supports Tailscale's DNS configuration and MagicDNS.
# Please have a look to their KB to better understand the concepts:
#
# - https://tailscale.com/kb/1054/dns/
# - https://tailscale.com/kb/1081/magicdns/
# - https://tailscale.com/blog/2021-09-private-dns-with-magicdns/
#
dns_config:
  # Whether to prefer using Headscale provided DNS or use local.
  override_local_dns: false

  # List of DNS servers to expose to clients.
  nameservers:
    - 223.5.5.5

  # NextDNS (see https://tailscale.com/kb/1218/nextdns/).
  # "abc123" is example NextDNS ID, replace with yours.
  #
  # With metadata sharing:
  # nameservers:
  #   - https://dns.nextdns.io/abc123
  #
  # Without metadata sharing:
  # nameservers:
  #   - 2a07:a8c0::ab:c123
  #   - 2a07:a8c1::ab:c123

  # Split DNS (see https://tailscale.com/kb/1054/dns/),
  # list of search domains and the DNS to query for each one.
  #
  # restricted_nameservers:
  #   foo.bar.com:
  #     - 1.1.1.1
  #   darp.headscale.net:
  #     - 1.1.1.1
  #     - 8.8.8.8

  # Search domains to inject.
  domains: []

  # Extra DNS records
  # so far only A-records are supported (on the tailscale side)
  # See https://github.com/juanfont/headscale/blob/main/docs/dns-records.md#Limitations
  # extra_records:
  #   - name: "grafana.myvpn.example.com"
  #     type: "A"
  #     value: "100.64.0.3"
  #
  #   # you can also put it in one line
  #   - { name: "prometheus.myvpn.example.com", type: "A", value: "100.64.0.3" }

  # Whether to use [MagicDNS](https://tailscale.com/kb/1081/magicdns/).
  # Only works if there is at least a nameserver defined.
  magic_dns: true

  # Defines the base domain to create the hostnames for MagicDNS.
  # `base_domain` must be a FQDNs, without the trailing dot.
  # The FQDN of the hosts will be
  # `hostname.user.base_domain` (e.g., _myhost.myuser.example.com_).
  base_domain: example.com

# Unix socket used for the CLI to connect without authentication
# Note: for production you will want to set this to something like:
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
#
# headscale supports experimental OpenID connect support,
# it is still being tested and might have some bugs, please
# help us test it.
# OpenID Connect
# oidc:
#   only_start_if_oidc_is_available: true
#   issuer: "https://your-oidc.issuer.com/path"
#   client_id: "your-oidc-client-id"
#   client_secret: "your-oidc-client-secret"
#   # Alternatively, set `client_secret_path` to read the secret from the file.
#   # It resolves environment variables, making integration to systemd's
#   # `LoadCredential` straightforward:
#   client_secret_path: "${CREDENTIALS_DIRECTORY}/oidc_client_secret"
#   # client_secret and client_secret_path are mutually exclusive.
#
#   # The amount of time from a node is authenticated with OpenID until it
#   # expires and needs to reauthenticate.
#   # Setting the value to "0" will mean no expiry.
#   expiry: 180d
#
#   # Use the expiry from the token received from OpenID when the user logged
#   # in, this will typically lead to frequent need to reauthenticate and should
#   # only been enabled if you know what you are doing.
#   # Note: enabling this will cause `oidc.expiry` to be ignored.
#   use_expiry_from_token: false
#
#   # Customize the scopes used in the OIDC flow, defaults to "openid", "profile" and "email" and add custom query
#   # parameters to the Authorize Endpoint request. Scopes default to "openid", "profile" and "email".
#
#   scope: ["openid", "profile", "email", "custom"]
#   extra_params:
#     domain_hint: example.com
#
#   # List allowed principal domains and/or users. If an authenticated user's domain is not in this list, the
#   # authentication request will be rejected.
#
#   allowed_domains:
#     - example.com
#   # Note: Groups from keycloak have a leading '/'
#   allowed_groups:
#     - /headscale
#   allowed_users:
#     - alice@example.com
#
#   # If `strip_email_domain` is set to `true`, the domain part of the username email address will be removed.
#   # This will transform `first-name.last-name@example.com` to the user `first-name.last-name`
#   # If `strip_email_domain` is set to `false` the domain part will NOT be removed resulting to the following
#   user: `first-name.last-name.example.com`
#
#   strip_email_domain: true

# Logtail configuration
# Logtail is Tailscales logging and auditing infrastructure, it allows the control panel
# to instruct tailscale nodes to log their activity to a remote server.
logtail:
  # Enable logtail for this headscales clients.
  # As there is currently no support for overriding the log server in headscale, this is
  # disabled by default. Enabling this will make your clients send logs to Tailscale Inc.
  enabled: false

# Enabling this option makes devices prefer a random port for WireGuard traffic over the
# default static port 41641. This option is intended as a workaround for some buggy
# firewall devices. See https://tailscale.com/kb/1181/firewalls/ for more information.
randomize_client_port: false
```

```yaml
# traefik/config/dynamic_conf.yml
http:
  middlewares:
    basic-auth:
      basicAuth:
        users:
          - "root:$2y$10$hMOhcTbgWyaaQ9cF/0ttsegipunZ.HnsV7DRuEfRTBFAKH6K6sXmu" # root:123456, by https://bcrypt.online/
    allow-cors:
      headers:
        accessControlAllowMethods: "*"
        accessControlAllowHeaders: "*"
        accessControlAllowOriginList: "*"
```

运行服务

```bash
docker compose up -d
```

生成 API Key

```bash
docker exec -it headscale headscale apikeys create
```

可以通过访问 <https://headscale-ui.cloud.example.com:30000> 进入 Dashboard，填入 <https://headscale.cloud.example.com:30000> 和 API Key 

创建用户

```bash
docker exec -it headscale headscale namespaces create htqi
```

### 普通设备加入

对于云服务器、笔记本电脑、手机等设备，安装 Tailscale 客户端

在 Headscale 控制中心服务器生成 preauthkey，每个 preauthkey 只能使用一次

```bash
docker exec -it headscale headscale preauthkeys create --user htqi
```

在设备上运行

```bash
# `login-server` 是 Headscale 控制中心地址
# `accept-routes=true` 是接收其他设备公布的子网
# `accept-dns=false` 是不让 Tailscale 乱搞 DNS
# `auth-key` 是 preauthkey
# `hostname` 是注册的设备名，也可以留空使用系统的 hostname
tailscale up --login-server=https://headscale.cloud.example.com:30000 --accept-routes=true --accept-dns=false --auth-key $preauthkey --hostname DEVICE1
```

### 家庭网络旁路由加入

先生成 preauthkey

在设备上运行

```bash
# 通过 `--advertise-routes=192.168.1.0/24` 参数公布子网
tailscale up --advertise-routes=192.168.1.0/24 --login-server=https://headscale.be.wizzstudio.com:30000 --accept-routes=true --accept-dns=false --auth-key $preauthkey --hostname HOME_DEVICE1
```

在 Headscale 控制中心服务器 查看路由列表

```bash
docker exec -it headscale headscale routes list
# ID | Node       | Prefix           | Advertised | Enabled | Primary
# 1  |HOME_DEVICE1| 192.168.1.0/24  | true       | false    | false
```

根据 ID 启用路由

```bash
docker exec -it headscale headscale routes enable -r 1
```

此时所有安装 Tailscale 的设备都可以访问 `192.168.1.0/24` 了，比如 `192.168.1.3`。同理，在家庭网络2中的设备也可以通过类似的方式加入虚拟网络，公布 `192.168.2.0/24`。

但是此时 家庭网络1 的其他设备，比如 `192.168.1.3`，无法访问 `192.168.2.3`。需要在家庭网络1 的网关上添加路由，将 `192.168.2.0/24` 的流量转发到 `192.168.1.2`。

首先启用 `192.168.1.2` 的转发功能。注意，每个发行版的配置方法可能不同，以下是 ArchLinux 的配置方法。

```bash
# ArchLinux
# https://wiki.archlinux.org/title/Internet_sharing#Enable_packet_forwarding
cat << EOF > /etc/sysctl.d/30-ipforward.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system
```

再启用 NAT 转发

```bash
# ArchLinux with Docker
# https://wiki.archlinux.org/title/Internet_sharing#With_iptables
iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
iptables -I DOCKER-USER 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I DOCKER-USER 2 -i ens18 -o tailscale0 -j ACCEPT
```

其中流量从 `ens18` 网口进入，通往 `tailscale0` 网口。每个设备的网口可能不同，可以通过 `ip a` 查看。需要注意的是，这些更改会在重启后失效。

然后在家庭网络1 的 OpenWRT 网关上添加路由

网络 - 路由 - 静态 IPv4 路由 - 添加 - (LAN, unicast, 192.168.2.0/24, 192.168.1.2) 

再补上默认虚拟内网的路由 `10.64.0.0/16`

网络 - 路由 - 静态 IPv4 路由 - 添加 - (LAN, unicast, 10.64.0.0/16, 192.168.1.2) 

此时家庭网络1 的设备就可以访问家庭网络2 的设备了。比如 `192.168.1.3` 和 `192.168.2.3`, 尽管都没有安装 Tailscale 客户端，但已经可以互相访问了。

### Derper

Derper 作为流量转发的中继服务器，为了防止被别人白嫖，需要在同设备上安装 Tailscale，然后对客户端进行认证。我将 Derper 部署也部署在了 `192.168.1.2` 上。

```yaml
# docker-compose.yml
services:
  derper:
    # https://github.com/yangchuansheng/ip_derper/blob/main/Dockerfile
    image: ghcr.io/yangchuansheng/derper
    container_name: derper
    restart: unless-stopped
    environment:
        # https://icloudnative.io/posts/custom-derp-servers/
        # https://github.com/fredliang44/derper-docker
        - DERP_CERT_MODE=letsencrypt
        - DERP_ADDR=:12345
        - DERP_DOMAIN=derper.homenet1.example.com
        - DERP_VERIFY_CLIENTS=true
    volumes:
      -  /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.derper.rule=Host(`derper.homenet1.example.com`)"
      - "traefik.http.routers.derper.tls=true"
      - "traefik.http.services.derper.loadbalancer.server.port=12345"
    network_mode: host # allow IPv6
```

通过传递 `DERP_VERIFY_CLIENTS=true` 参数、传入 Tailscale 的 `tailscaled.sock` 文件，可以对客户端进行认证。

运行

```bash
docker compose up -d
```

浏览器访问 <https://derper.homenet1.example.com:20000>，可以看到 `This is a Tailscale DERP server.` 即为搭建成功。同理，家庭网络2 也可以搭建一个 Derper，网址为 <https://derper.homenet2.example.com:20000>

在家庭网络的网关上添加端口映射，将 `3478/udp` 指向 `192.168.1.2:3478`

然后在 Headscale 控制中心服务器添加 DERP 服务器

```yaml
# ./config/config.yml
derp:
# disable default DERP server
#   urls:
#     - https://controlplane.tailscale.com/derpmap/default
  paths:
    - /etc/headscale/derp.yaml
```

```yaml
# ./config/derp.yaml
regions:
  900:
    regionid: 900
    regioncode: home1
    regionname: home1
    nodes:
      - name: home1-server
        regionid: 900
        hostname: derper.homenet1.example.com
        stunport: 3478
        stunonly: false
        derpport: 20000
  901:
    regionid: 901
    regioncode: home2
    regionname: home2
    nodes:
      - name: home2-server
        regionid: 901
        hostname: derper.homenet2.example.com
        stunport: 3478
        stunonly: false
        derpport: 20000
```

重启容器

```sh
docker compose restart
```

在有 tailscale 的设备上运行

```bash
tailscale netcheck
# Report:
#         * Nearest DERP: home1
#         * DERP latency:
#                 -  home1: 2ms   (home1)
#                 -  home2: 5.6ms (home2)
```

就说明 Derper 部署成功了。Tailscale 会挑选延迟最低的 DERP 服务器。

## ref

<https://icloudnative.io/posts/custom-derp-servers/>
