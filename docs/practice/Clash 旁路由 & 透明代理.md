# Clash 旁路由 & 透明代理

## 需求

完成代理配置后，局域网设备不需要任何配置，即可实现科学上网。

最简单的方案是在主路由上安装 OpenClash，但是这样会有一些问题：

- 主路由的性能可能不够，运行 OpenClash 会导致网络卡顿。
- OpenClash 基于 Clash，又进行了一层便于小白使用的封装。我对于 OpenClash 的感觉就是需要安装一堆奇怪的依赖，启动后会向 iptables 等地方添加一堆奇怪的规则，然后就成功实现透明代理了。但是出问题后因为 OpenClash 有点类似于黑箱，排查问题比较困难。
- OpenClash 的 LuCI 界面卡卡的，不流畅。

所以我选择了在旁路由 (x86 Linux 服务器) 上安装 Clash，实现透明代理。

## 方案

假设局域网 IP 段为 `192.168.1.0/24`；主路由 IP 为 `192.168.1.1`, 运行 OpenWrt；旁路由 IP 为 `192.168.1.2`，x86 服务器，运行 ArchLinux。手机作为接入网络的设备，不需要修改任何设置、安装任何软件，即可实现科学上网。

1. 主路由将旁路由 `192.168.1.2:53` 设置为上级 DNS 服务器。
2. 手机访问 `www.baidu.com` or `www.google.com`，DNS 请求被转发到旁路由。
3. 旁路由运行 Clash，Clash 在 `192.168.1.2:53` 提供 DNS 服务。基于 [dnsmasq-china-list](https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf) 提供的国内域名列表进行分流，`www.baidu.com` 是国内域名，查询上层 DNS 服务器 `https://dns.alidns.com/dns-query`，返回 `www.baidu.com` 的 IP 地址 `39.156.66.10`; `www.google.com` 是国外域名，查询上层 DNS 服务器 `https://dns.cloudflare.com/dns-query`，返回 `www.google.com` 的 Fake IP `198.18.0.4`, 同时 Clash 保存 `198.18.0.4` 到 `www.google.com` 的映射关系。
4. 主路由设置了路由规则，将 Fake IP 网段 `198.18.0.0/16` 指向了旁路由 `192.168.1.2`. 手机访问 `www.baidu.com` 时，请求不经过旁路由，直接访问；访问 `www.google.com` 时，请求被转发到旁路由。
5. 旁路由收到 `198.18.0.4` 的 TProxy 请求，Clash 会根据映射规则得知手机想要访问 `www.google.com`，然后进行请求代理。

尽管我非常喜欢使用 Docker，但是 Docker 也会对 iptables 进行一些修改，导致一些额外复杂度的引入。所以我选择二进制 + Systemd 服务的方式运行 Clash，比较简单。

## 步骤

### 旁路由允许转发

```sh
cat << EOF > /etc/sysctl.d/99-sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system
```

### 旁路由禁止 systemd-resolved 占用 53 端口
    
我的 ArchLinux 使用 systemd-resolved，它会占用 53 端口，会和 Clash 冲突。所以需要禁止 systemd-resolved 占用 53 端口。

```sh
mkdir -p /etc/systemd/resolved.conf.d
cat << EOF > /etc/systemd/resolved.conf.d/disable.conf
[Resolve]
DNSStubListener=no
EOF
systemctl restart systemd-resolved
```

开启 `DNSStubListener=no` 后，systemd-resolved 会停止监听 53 端口，并仍能正常进行解析工作。

ref [Getting rid of systemd-resolved consuming port 53](https://medium.com/@niktrix/getting-rid-of-systemd-resolved-consuming-port-53-605f0234f32f), [Systemd-resolved DNSStubListener](https://www.reddit.com/r/systemd/comments/gnuar4/comment/frbybuq/?utm_source=share&utm_medium=web2x&context=3)

### 旁路由安装 Clash

安装 Clash

```sh
mkdir -p /root/clash
cd /root/clash
wget https://downloads.clash.wiki/ClashPremium/clash-linux-amd64-2023.08.17.gz && gzip -d clash-linux-amd64-2023.08.17.gz && mv ./clash-linux-amd64-2023.08.17 clash && chmod +x clash
```

准备 Clash 配置文件，记得将 proxies 设置为自己的代理服务器，并修改 secret。

```sh
cat << EOF > /root/clash/config.yaml.source
# restful api
external-controller: 0.0.0.0:9090
# 保护 restful api 的口令，记得修改
secret: "SET YOUR SECRET"
# 日志级别，info / warning / error / debug / silent，调试时设为 debug。平时可以设置更高的日志级别，减少日志量。
log-level: debug
# HTTP(S) 和 SOCKS4(A)/SOCKS5 代理服务共用端口
mixed-port: 1080
# Linux 的透明代理服务端口 (TProxy TCP 和 TProxy UDP)
tproxy-port: 1081
# Clash 路由工作模式
# rule: 基于规则的数据包路由
# global: 所有数据包将被转发到单个节点
# direct: 直接将数据包转发到互联网
mode: rule
# 设置为 true 以允许来自其他 LAN IP 地址的连接
allow-lan: true
# allow-lan == true 时，绑定所有 IP 地址
bind-address: '*'
profile:
# 持久化 Fake IP 映射关系
store-fake-ip: true
dns:
enable: true
listen: 0.0.0.0:53
ipv6: true
# 用于解析下列 DNS 服务器的域名，比如 dns.alidns.com
default-nameserver:
- 223.5.5.5
- 223.6.6.6
enhanced-mode: fake-ip
use-hosts: true
# Fake IP 地址池 CIDR
fake-ip-range: 198.18.0.1/16

# 如果域名匹配 fallback-filter（国外域名），DNS 服务器列表为 fallback
# 如果域名不匹配 fallback-filter（国内域名），DNS 服务器列表为 nameserver + fallback
# Clash 会向 DNS 服务器列表的所有服务器并发发送请求
# 并使用第一个收到的响应作为 DNS 查询的结果.

# nameserver 为仅用于国内域名的 DNS 服务器列表
nameserver:
- https://doh.pub/dns-query
- https://dns.alidns.com/dns-query
# fallback 国内域名、国外域名都会使用的 DNS 服务器列表
fallback:
- https://doh.dns.sb/dns-query
- https://dns.cloudflare.com/dns-query
- https://dns.twnic.tw/dns-query
- tls://8.8.4.4:853
# fallback-filter 用于判断域名是否为国外域名
fallback-filter:
    geoip: true
    ipcidr:
    - 240.0.0.0/4
    - 0.0.0.0/32
# proxies 设置为自己的代理服务器
EOF
```

ref [Clash 参考配置](https://clash.wiki/configuration/configuration-reference.html)

Clash 将占用以下端口：

- 53/udp: DNS 服务
- 9090/tcp: RESTful API
- 1080/tcp: HTTP(S) / SOCKS5 代理服务，局域网设备可以手动设置代理服务器为 `socks5://192.168.1.2:1080` 或 `http://192.168.1.2:1080` 实现科学上网
- 1081/tcp, 1081/udp: TProxy 透明代理服务

### 旁路由设置中国域名更新

```sh
cat << EOF > /root/clash/china_domain_update.py
#!/usr/bin/env python

import os
import urllib.request
import subprocess
from pathlib import Path
from yaml import load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


def main():
    file_dnsmasq_china = Path("./accelerated-domains.china.conf")
    # url = "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"    
    url = "https://gitee.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf"
    subprocess.run(["wget", url, "-O", str(file_dnsmasq_china)], check=True)

    fakeip_direct_rules = '''*.lan
*.localdomain
*.example
*.invalid
*.localhost
*.test
*.local
*.home.arpa
time.*.com
time.*.gov
time.*.edu.cn
time.*.apple.com
ntp.*.com
*.time.edu.cn
*.ntp.org.cn
+.pool.ntp.org
time1.cloud.tencent.com
*.cn'''.splitlines()

    lines = file_dnsmasq_china.read_text().splitlines()
    for line in lines:
        # server=/00058.com/114.114.114.114 -> 00058.com
        domain = line.split("/")[-2].strip()
        fakeip_direct_rules.append(f"+.{domain}")


    file_clash_config_source = Path("/root/clash/config.yaml.source")
    file_clash_config = Path("/root/clash/config.yaml")
    config = load(file_clash_config_source.read_text(), Loader=Loader)
    config['dns']['fake-ip-filter'] = fakeip_direct_rules
    file_clash_config.write_text(dump(config, Dumper=Dumper, allow_unicode=True))


if __name__ == '__main__':
    main()
EOF

chmod +x /root/clash/china_domain_update.py
```

运行脚本，下载最新的中国域名列表，并更新 Clash 配置文件。

```sh
/root/clash/china_domain_update.py
```

也可以编写 Systemd 服务，每天 4:00 更新一次。

```sh
cat << EOF > /etc/systemd/system/clash_china_domain_update.service
[Unit]
Description=Clash China Domain Update
After=network.target

[Service]
Type=oneshot
ExecStart=/root/clash/china_domain_update.py

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/clash_china_domain_update.timer
[Unit]
Description=Clash China Domain Update Timer

[Timer]
OnCalendar=*-*-* 04:00:00
Unit=clash_china_domain_update.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now clash_china_domain_update.timer
```

### 旁路由设置 Clash 服务

新建 Systemd 服务

```sh
cat << EOF > /etc/systemd/system/clash.service
[Unit]
Description="Clash is a cross-platform rule-based proxy utility that runs on the network and application layer."
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/root/clash/clash -d /root/clash

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now clash
```

###  旁路由设置 TProxy 的相关 iptables 规则

```sh
cat << EOF > /root/clash/clash_tproxy_iptables_setup.sh
#!/usr/bin/env bash

# ROUTE RULES
ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

# CREATE TABLE
iptables -t mangle -N clash

# RETURN LOCAL AND LANS
iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A clash -d 192.168.50.0/16 -j RETURN
iptables -t mangle -A clash -d 192.168.9.0/16 -j RETURN

iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN

# FORWARD ALL
iptables -t mangle -A clash -p udp -j TPROXY --on-port 1081 --tproxy-mark 1
iptables -t mangle -A clash -p tcp -j TPROXY --on-port 1081 --tproxy-mark 1

# HIJACK ICMP (untested)
# iptables -t mangle -A clash -p icmp -j DNAT --to-destination 127.0.0.1

# REDIRECT
iptables -t mangle -A PREROUTING -j clash
EOF
chmod +x /root/clash/clash_tproxy_iptables_setup.sh
```

编写 Systemd 服务，每次启动时设置 TProxy 规则。

```sh
cat << EOF > /etc/systemd/system/clash_tproxy_iptables_setup.service
[Unit]
Description=Clash TProxy IPTables Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash /root/clash/clash_tproxy_iptables_setup.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now clash_tproxy_iptables_setup.service
```

### OpenWrt 主路由设置路由规则

将 Fake IP 网段 `198.18.0.0/16` 指向旁路由

网络 - 路由 - 添加: LAN, unicast, 198.18.0.0/16, 192.168.1.2

### OpenWrt 主路由设置旁路由为上级 DNS

网络 - DHCP/DNS - 常规设置 - DNS 转发 - 添加 192.168.1.2

网络 - DHCP/DNS - HOSTS 和解析文件 - 忽略解析文件

## 运维

检查 DNS 解析是否正确

```sh
# baidu.com 应解析为直连 ip，如 39.156.66.10
dig baidu.com
# google.com 应解析为 Fake IP，如 198.18.0.4
dig google.com

/etc/init.d/dnsmasq restart # 重启 dnsmasq
/etc/init.d/uhttpd restart # 重启 luci
```

## 缺点

- 仅根据域名白名单进行分流，可能不准确
