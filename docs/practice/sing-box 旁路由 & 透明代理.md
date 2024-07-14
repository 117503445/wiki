# sing-box 旁路由 & 透明代理

## 前言

在 [Clash 旁路由 & 透明代理](https://wiki.117503445.top/practice/Clash%20%E6%97%81%E8%B7%AF%E7%94%B1%20%26%20%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86/) 方案使用了半年后，发现此方案存在一些问题

1. Clash 已经停止维护
2. DNS 依赖旁路由。一旦旁路由宕机，整个家里都会无法上网。

本文对先前的方案进行了升级。

1. 使用 [sing-box](https://github.com/SagerNet/sing-box) 替代 Clash，它具有更强大的路由功能和更广泛的协议支持
2. 使用 [mosdns](https://github.com/IrineSistiana/mosdns) 作为 DNS 转发器，确保只要主路由正常，就能正常访问国内网站。

## 需求

完成代理配置后，局域网设备不需要任何配置，即可实现科学上网。

最简单的方案是在主路由上安装 OpenClash，但是这样会有一些问题：

- 主路由的性能可能不够，运行 OpenClash 会导致网络卡顿。
- OpenClash 基于 Clash，又进行了一层便于小白使用的封装。我对于 OpenClash 的感觉就是需要安装一堆奇怪的依赖，启动后会向 iptables 等地方添加一堆奇怪的规则，然后就成功实现透明代理了。但是出问题后因为 OpenClash 有点类似于黑箱，排查问题比较困难。
- OpenClash 的 LuCI 界面卡卡的，不流畅。

因此，提炼出新的需求

1. 使用一款可靠的代理软件，清楚其每个配置项的作用。甚至能阅读源码，以便排查问题。
2. 数据加密、混淆在旁路由上完成，主路由只需付出少量的计算开销。
3. 旁路由挂了以后，仍能正常访问国内网站。

所以我选择了在旁路由 (x86 Linux 服务器) 上安装 sing-box，实现透明代理。

## 方案

大致方案就是对 DNS 请求进行分流，国内域名直接查询上级 DNS 服务器，国外域名解析到 `198.18.0.0/16` FakeIP 网段。然后将 FakeIP 网段指向旁路由，旁路由收到 FakeIP 请求后，再进行代理。

假设局域网 IP 段为 `192.168.1.0/24`；主路由 IP 为 `192.168.1.1`, 运行 OpenWrt；旁路由 IP 为 `192.168.1.2`，x86 服务器，运行 ArchLinux。手机作为接入网络的设备，不需要修改任何设置、安装任何软件，即可实现科学上网。

流程如下：

1. 主路由在 `192.168.1.1:5353` 运行 mosdns，并将默认 DNS 服务器 dnsmasq 的上级 DNS 服务器设置为 `192.168.1.1:5353`。mosdns 将旁路由 DNS `192.168.1.2:5335` 设置为主要 DNS 服务器，将 `223.5.5.5` 设置为 Fallback DNS 服务器。在解析 DNS 请求时，mosdns 会向 2 个 DNS 服务器同时发起查询。如果旁路由 DNS 挂了，mosdns 在等待 500ms 后，会使用 Fallback DNS 返回的结果。之所以要引入 mosdns 而不是直接使用默认的 dnsmasq，是因为 dnsmasq 不支持这样的 fallback 机制。
2. 手机访问 `www.baidu.com` or `www.google.com`，DNS 请求被转发到旁路由。
3. 旁路由运行 sing-box，sing-box 在 `192.168.1.2:5335` 提供 DNS 服务。对于国内域名，查询上层 DNS 服务器 `h3://dns.alidns.com/dns-query`，返回 `www.baidu.com` 的 IP 地址 `39.156.66.10`; `www.google.com` 是国外域名，查询上层 DNS 服务器 `https://1.1.1.1/dns-query`，返回 `www.google.com` 的 Fake IP `198.18.0.4`, 同时 sing-box 保存 `198.18.0.4` 到 `www.google.com` 的映射关系。
4. 主路由设置了路由规则，将 Fake IP 网段 `198.18.0.0/16` 指向了旁路由 `192.168.1.2`. 手机访问 `www.baidu.com` 时，请求不经过旁路由，直接访问；访问 `www.google.com` 时，请求被转发到旁路由。
5. 旁路由收到 `198.18.0.4` 的 TProxy 请求，sing-box 会根据映射规则得知手机想要访问 `www.google.com`，然后进行请求代理。

尽管我非常喜欢使用 Docker，但是 Docker 也会对 iptables 进行一些修改，导致一些额外复杂度的引入。所以我通过 PVE 以虚拟机的形式进行隔离，在代理专用 ArchLinux 虚拟机中不安装 Docker，而是直接运行二进制 + Systemd 服务的方式运行 sing-box。

## 步骤

### 旁路由配置 sing-box

安装 sing-box

```sh
yay -Sy sing-box-bin --noconfirm # https://sing-box.sagernet.org/installation/package-manager/
```

准备配置文件

- 将 `YOUR_UI_PASSWORD` 替换为自己的密码
- 将 `outbounds` 设置为自己的服务器，其中注意到 server0 也被用于 OpenAI 等服务的 outbound，所以将 `outbounds` 替换为自己服务器后，需要将 server0 也替换为自己某一台服务器的 tag

```jsonc
// /etc/sing-box/config.json
{
  // https://sing-box.sagernet.org/configuration/log/
  "log": {
    "disabled": false,
    "level": "trace",
    "timestamp": true
  },
  "experimental": {
    // https://sing-box.sagernet.org/configuration/experimental/cache-file/
    "cache_file": {
      "enabled": true, // 启用缓存文件功能。当此项设置为 true 时，启用 DNS 查询的缓存，以便加快后续相同查询的响应速度。
      "store_fakeip": true, // 将 fakeip 存储在缓存文件中
      "store_rdrc": false // 将拒绝的 DNS 响应缓存存储在缓存文件中
    },
    // https://sing-box.sagernet.org/configuration/experimental/clash-api/
    "clash_api": {
      "external_controller": "0.0.0.0:9090", // 定义 Clash API 的外部控制器地址。"0.0.0.0:9090" 表示在本机的9090端口上监听外部的连接请求。
      "default_mode": "rule", // 设置 Clash API 的默认模式。"rule" 模式意味着流量将根据用户定义的规则进行路由。
      "external_ui": "metacubexd", // 指定外部用户界面(UI)的名称。这里的 "metacubexd" 是一个自定义 UI 的名称。
      "external_ui_download_url": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip", // 提供外部 UI 的下载 URL。这个 URL 是从 GitHub 上下载 "metacubexd" UI 的压缩包。
      "external_ui_download_detour": "select", // 定义下载外部 UI 时使用的转发策略。"select" 表示将通过'select'出口选择转发
      "secret": "YOUR_UI_PASSWORD"
    }
  },
  "dns": {
    // https://sing-box.sagernet.org/configuration/dns/server/
    "servers": [
      {
        "tag": "dns_proxy",
        "address": "https://1.1.1.1/dns-query",
        "address_resolver": "dns_resolver",
        "strategy": "prefer_ipv4",
        "detour": "select" // 用于连接 dns 服务器的出站 tag
      },
      {
        "tag": "dns_direct",
        "address": "h3://dns.alidns.com/dns-query",
        "address_resolver": "dns_resolver",
        "strategy": "prefer_ipv4",
        "detour": "direct" // 用于连接 dns 服务器的出站 tag
      },
      {
        "tag": "dns_block",
        "address": "rcode://refused" // Query refused
      },
      {
        "tag": "dns_resolver", // 用于解析地址中域名的另一台 DNS 服务器
        "address": "223.5.5.5",
        "strategy": "prefer_ipv4",
        "detour": "direct"
      },
      {
        "tag": "dns_fakeip",
        "address": "fakeip"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/15",
      "inet6_range": "fc00::/18"
    },
    "independent_cache": true, // 使每个 DNS 服务器的缓存独立，以满足特殊目的。如果启用，将轻微降低性能。 https://sing-box.sagernet.org/zh/configuration/dns/#independent_cache
    "rules": [
      {
        "outbound": "any",
        "server": "dns_resolver"
        // 注释：对于任何出站连接（不管是直接连接还是通过代理），使用 "dns_resolver" 服务器进行 DNS 解析（这一句主要用来解析代理节点本身的 IP 地址）。
      },
      {
        "type": "logical",
        "mode": "and",
        "rules": [
          {
            "inbound": "dns-in"
          },
          {
            "type": "logical",
            "mode": "or",
            "rules": [
              {
                "rule_set": "geosite-geolocation-!cn",
                "server": "dns_proxy"
                // 注释：对于 geosite 数据库中定义的非中国地区的地理位置相关的域名，使用 "dns_proxy" 服务器通过代理进行 DNS 解析。
              }
            ]
          }
        ],
        "server": "dns_fakeip"
      },
      {
        "process_name": [
          "TencentMeeting",
          "NemoDesktop",
          "ToDesk",
          "ToDesk_Service",
          "WeChat",
          "Tailscale",
          "wireguard-go",
          "Tunnelblick",
          "softwareupdated",
          "kubectl"
        ],
        "server": "dns_direct"
        // 注释：当特定的进程（如 TencentMeeting、WeChat 等）发起 DNS 请求时，使用 "dns_direct" 服务器进行直连 DNS 解析。
      },
      {
        "domain_suffix": [
          "icloudnative.io",
          "fuckcloudnative.io",
          "sealos.io",
          "cdn.jsdelivr.net"
        ],
        "server": "dns_direct"
        // 注释：对于特定后缀的域名（如 icloudnative.io 等），使用 "dns_direct" 服务器进行直连 DNS 解析。
      },
      {
        "package_name": [
          "com.google.android.youtube",
          "com.android.vending",
          "org.telegram.messenger",
          "org.telegram.plus"
        ],
        "server": "dns_proxy"
        // 注释：对于特定的 Android 应用包名（如 YouTube、Telegram 等），使用 "dns_proxy" 服务器通过代理进行 DNS 解析。
      },
      {
        "rule_set": "geosite-geolocation-!cn",
        "server": "dns_proxy"
        // 注释：对于 geosite 数据库中定义的非中国地区的地理位置相关的域名，使用 "dns_proxy" 服务器通过代理进行 DNS 解析。
      },
      {
        "rule_set": "Global",
        "server": "dns_proxy"
        // 注释：对于定义在 "Global" 规则集中的域名，使用 "dns_proxy" 服务器通过代理进行 DNS 解析。
      },
      {
        "rule_set": [
          "YouTube",
          "Telegram",
          "Netflix",
          "geoip-google",
          "geoip-telegram",
          "geoip-twitter",
          "geoip-netflix"
        ],
        "server": "dns_proxy"
        // 注释：对于特定的服务和地理位置相关的域名（如 YouTube、Netflix、谷歌、Telegram 相关的域名），使用 "dns_proxy" 服务器通过代理进行 DNS 解析。
      }
    ],
    "final": "dns_direct", // 注释：如果上述规则都不适用，则默认使用 "dns_direct" 服务器进行直连 DNS 解析。
    "strategy": "prefer_ipv4" // 解析域名的默认域策略
  },
  "inbounds": [
    {
      "type": "direct", // https://sing-box.sagernet.org/configuration/inbound/direct/
      "tag": "dns-in",
      "network": "udp",
      // https://sing-box.sagernet.org/configuration/shared/listen/
      "listen": "::",
      "listen_port": 5335,
      "sniff": true // 表示启用流量嗅探功能，以便自动检测和处理传入的数据流类型。https://sing-box.sagernet.org/configuration/route/sniff/
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "::",
      "listen_port": 1080,
      "sniff": true // 表示启用流量嗅探功能，以便自动检测和处理传入的数据流类型。https://sing-box.sagernet.org/configuration/route/sniff/
    },
    {
      "type": "tproxy",
      "tag": "tproxy-in",
      "listen": "::",
      "listen_port": 1081,
      "sniff": true // 表示启用流量嗅探功能，以便自动检测和处理传入的数据流类型。https://sing-box.sagernet.org/configuration/route/sniff/
    }
  ],
  "outbounds": [
    {
      "tag": "select",
      "type": "selector",
      "default": "自动选择",
      "outbounds": [
        "自动选择",
        "server0",
        "server1"
      ]
    },
    {
      "type": "direct", // 直连类型，不通过代理直接访问
      "tag": "direct" // 标签名为 "direct"
    },
    {
      "type": "block", // 阻止类型，用于拦截流量
      "tag": "block" // 标签名为 "block"
    },
    {
      "type": "dns", // DNS 类型，用于 DNS 查询
      "tag": "dns-out" // 标签名为 "dns-out"
    },
    {
      "type": "selector", // 同样是选择器类型
      "tag": "openai", // 标签名为 "openai"
      "outbounds": [
        "server0" // 可选择的出站仍然是 "server0"
      ],
      "default": "server0" // 默认选择的出站同样是 "server0"
    },
    {
      "type": "selector", // 选择器类型
      "tag": "tiktok", // 标签名为 "tiktok"
      "outbounds": [
        "server0" // 可选择的出站是 "server0"
      ],
      "default": "server0" // 默认选择的出站为 "server0"
    },
    {
      "tag": "server0",
      "type": "hysteria2",
      "server": "",
      "server_port": 443,
      "up_mbps": 20,
      "down_mbps": 50,
      "password": "",
      "tls": {
        "enabled": true,
        "server_name": ""
      }
    },
    {
      "tag": "server1",
      "type": "vmess",
      "server": "",
      "server_port": 443,
      "uuid": "",
      "security": "auto",
      "alter_id": 0,
      "transport": {
        "type": "ws",
        "path": "/v2",
        "max_early_data": 2048,
        "early_data_header_name": "sec-websocket-protocol"
      },
      "tls": {
        "enabled": true,
        "insecure": false,
        "server_name": null
      }
    },
    {
      "tag": "自动选择",
      "type": "urltest",
      "outbounds": [
        "server0",
        "server1"
      ]
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns", // 使用 DNS 协议的流量
        "outbound": "dns-out" // 将通过 `dns-out` 出口转发
      },
      {
        "domain_suffix": [ // 特定后缀的域名
          "icloudnative.io",
          "fuckcloudnative.io",
          "sealos.io",
          "cdn.jsdelivr.net"
        ],
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "process_name": [ // 特定进程名称
          "TencentMeeting",
          "NemoDesktop"
        ],
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "rule_set": [ // 特定的规则集
          "WeChat",
          "Bilibili"
        ],
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "protocol": "quic", // 使用QUIC协议的流量
        "outbound": "block" // 将被阻止
      },
      {
        "rule_set": "OpenAI", // OpenAI规则集
        "outbound": "openai" // 将通过'openai'出口转发
      },
      {
        "domain_suffix": [ // OpenAI相关的域名后缀
          "openai.com",
          "oaistatic.com",
          "oaiusercontent.com"
        ],
        "outbound": "openai" // 将通过'openai'出口转发
      },
      {
        "package_name": "com.openai.chatgpt", // OpenAI ChatGPT应用包名
        "outbound": "openai" // 将通过'openai'出口转发
      },
      {
        "rule_set": "TikTok", // TikTok规则集
        "outbound": "tiktok" // 将通过'tiktok'出口转发
      },
      {
        "package_name": "com.zhiliaoapp.musically", // TikTok应用包名
        "outbound": "tiktok" // 将通过'tiktok'出口转发
      },
      {
        "domain_suffix": [ // 特定的域名后缀
          "depay.one",
          "orbstack.dev"
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "process_name": [ // 特定的进程名称
          "DropboxMacUpdate",
          "Dropbox"
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "package_name": [ // 特定应用包名
          "com.google.android.youtube"
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "domain": "accounts.google.com", // 特定的域名
        "domain_suffix": [ // 特定的域名后缀
          "sourceforge.net",
          "fhjasokiwq.com"
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "domain_suffix": "cloud.sealos.io", // 特定的域名后缀
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "type": "logical", // 逻辑类型规则
        "mode": "and", // 使用'and'模式
        "rules": [ // 组合规则
          {
            "rule_set": "geosite-geolocation-!cn"
          },
          {
            "rule_set": "geoip-cn",
            "invert": true
          }
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "rule_set": "Global", // Global规则集
        "outbound": "select" // 将通过'select'出口选择转发
      },
      {
        "rule_set": "geoip-cn", // 中国地理位置IP规则集
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "ip_is_private": true, // 私有IP地址
        "outbound": "direct" // 将通过'direct'出口直接连接
      },
      {
        "rule_set": [ // 特定的规则集
          "YouTube",
          "Telegram",
          "Netflix",
          "geoip-google",
          "geoip-telegram",
          "geoip-twitter",
          "geoip-netflix"
        ],
        "outbound": "select" // 将通过'select'出口选择转发
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-geolocation-!cn",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-geolocation-!cn.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/CHIZI-0618/v2ray-rules-dat/release/singbox_ip_rule_set/geoip-cn.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-google",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/CHIZI-0618/v2ray-rules-dat/release/singbox_ip_rule_set/geoip-google.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-telegram",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/CHIZI-0618/v2ray-rules-dat/release/singbox_ip_rule_set/geoip-telegram.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-twitter",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/CHIZI-0618/v2ray-rules-dat/release/singbox_ip_rule_set/geoip-twitter.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-netflix",
        "format": "binary",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/CHIZI-0618/v2ray-rules-dat/release/singbox_ip_rule_set/geoip-netflix.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "Global",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/Global.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "YouTube",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/YouTube.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "OpenAI",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/OpenAI.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "TikTok",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/TikTok.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "Telegram",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/Telegram.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "Netflix",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/Netflix.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "WeChat",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/WeChat.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "Bilibili",
        "format": "source",
        "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/yangchuansheng/sing-box-geosite/main/rule/Bilibili.json",
        "download_detour": "direct"
      }
    ],
    "auto_detect_interface": true,
    "final": "direct" // "final" 字段定义了默认的路由行为。这里设置为 "direct"，意味着如果没有匹配任何规则，流量将直接（不经代理）发送。
  }
}
EOF
```

ref
- [sing-box configuration](https://sing-box.sagernet.org/configuration/)
- [sing-box 基础教程：sing-box 的配置方法和使用教程](https://icloudnative.io/posts/sing-box-tutorial)

sing-box 将占用以下端口：

- 5335/udp: DNS 服务
- 9090/tcp: RESTful API
- 1080/tcp: HTTP(S) / SOCKS5 代理服务，局域网设备可以手动设置代理服务器为 `socks5://192.168.1.2:1080` 或 `http://192.168.1.2:1080` 实现科学上网
- 1081/tcp, 1081/udp: TProxy 透明代理服务

常用操作

```sh
systemctl enable --now sing-box # 启动 sing-box，并设置开机自启
journalctl -u sing-box --output cat -f # 查看 sing-box 日志
systemctl restart sing-box # 重启 sing-box
```

第一次运行 sing-box 后，sing-box 将下载 Web UI 和规则集。完成下载后，重启 sing-box 服务，就可以在 <http://192.168.1.2:9090/ui> 访问 Web UI，查看 sing-box 状态了。

### 旁路由设置 TProxy 的相关 iptables 规则

通过设置 iptables 规则，从而运行旁路由接收 TPorxy 请求后，转发到 sing-box 的 1081 端口。

```sh
mkdir -p /root/.app/singbox
cat << EOF > /root/.app/singbox/tproxy_iptables_setup.sh
#!/usr/bin/env bash

# ROUTE RULES
ip rule add fwmark 1 table 100
ip route add local 0.0.0.0/0 dev lo table 100

# CREATE TABLE
iptables -t mangle -N singbox

# RETURN LOCAL AND LANS
iptables -t mangle -A singbox -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A singbox -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A singbox -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A singbox -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A singbox -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A singbox -d 192.168.50.0/16 -j RETURN
iptables -t mangle -A singbox -d 192.168.9.0/16 -j RETURN

iptables -t mangle -A singbox -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A singbox -d 240.0.0.0/4 -j RETURN

# FORWARD ALL
iptables -t mangle -A singbox -p udp -j TPROXY --on-port 1081 --tproxy-mark 1
iptables -t mangle -A singbox -p tcp -j TPROXY --on-port 1081 --tproxy-mark 1

# HIJACK ICMP (untested)
# iptables -t mangle -A singbox -p icmp -j DNAT --to-destination 127.0.0.1

# REDIRECT
iptables -t mangle -A PREROUTING -j singbox
EOF
chmod +x /root/.app/singbox/tproxy_iptables_setup.sh
```

执行脚本并设置开机自启

```sh
cat << EOF > /etc/systemd/system/singbox_tproxy_iptables_setup.service
[Unit]
Description=singbox TProxy IPTables Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash /root/.app/singbox/tproxy_iptables_setup.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now singbox_tproxy_iptables_setup.service
```

### OpenWrt 主路由设置路由规则

将 Fake IP 网段 `198.18.0.0/16` 指向旁路由

OpenWrt LuCI - 网络 - 路由 - 添加: LAN, unicast, 198.18.0.0/16, 192.168.1.2

### OpenWrt 主路由配置 mosdns



下载 [mosdns](https://github.com/IrineSistiana/mosdns/releases)，将 `mosdns` 二进制放在 `/root/.app/mosdns/mosdns`。

准备配置文件

```yaml
// /root/.app/mosdns/config.yaml
log:
  level: debug

api:
  http: "192.168.1.1:8080" # 在该地址启动 api 接口。

plugins:
  - tag: forward_ali
    type: forward
    args:
      upstreams:
        - addr: https://223.5.5.5/dns-query
  - tag: forward_proxy
    type: forward
    args:
      upstreams:
        - addr: 192.168.1.2:5335
  - tag: "fallback_main"
    type: "fallback"
    args:
      primary: forward_proxy # 主可执行插件的 tag
      secondary: forward_ali # 副可执行插件的 tag
      threshold: 500 # 无响应回滚阈值。单位毫秒。默认 500 。
      always_standby: true # 副可执行插件始终待命。
  - tag: udp_server
    type: udp_server
    args:
      entry: fallback_main
      listen: 192.168.100.1:5353
```

运行 mosdns 并设置开机自启

```sh
cat << EOF > /etc/init.d/mosdns
#!/bin/bash /etc/rc.common

DAEMON_PATH="/root/.app/mosdns"
DAEMON=mosdns
DAEMONOPTS="start"

START=99
EXTRA_COMMANDS="status logs"
DAEMON_OUT_PATH="$DAEMON_PATH/out"
PIDFILE=/var/run/$DAEMON.pid

start() {
    printf "%-50s" "Starting $DAEMON..."
    cd $DAEMON_PATH
    PID=$(
        ./$DAEMON $DAEMONOPTS >$DAEMON_OUT_PATH 2>&1 &
        echo $!
    )
    if [ -z $PID ]; then
        printf "%s\n" "Fail"
    else
        echo $PID >$PIDFILE
        printf "%s\n" "Ok"
    fi
}

stop() {
    printf "%-50s" "Stopping $DAEMON"
    PID=$(cat $PIDFILE)
    cd $DAEMON_PATH
    if [ -f $PIDFILE ]; then
        kill -HUP $PID
        printf "%s\n" "Ok"
        rm -f $PIDFILE
    else
        printf "%s\n" "pidfile not found"
    fi
}

status() {
    echo status
    printf "%-50s" "Checking $DAEMON..."
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if [ -z "$(ps | grep ${PID} | grep -v grep)" ]; then
            printf "%s\n" "Process dead but pidfile exists"
        else
            echo "Running"
        fi
    else
        printf "%s\n" "Service not running"
    fi
}

logs() {
    tail -f $DAEMON_OUT_PATH
}
EOF
service mosdns enable
service mosdns start
```

调整 dnsmasq

```text
OpenWrt LuCI - 网络 - DHCP/DNS - 常规设置 - DNS 转发 - 添加 192.168.1.1:5353
OpenWrt LuCI - 网络 - DHCP/DNS - HOSTS 和解析文件 - 忽略解析文件

// 当存在域名指向 rfc1918 地址时，需禁用重定向保护
OpenWrt LuCI - 网络 - DHCP/DNS - 常规设置 - 重定向保护 - 取消
```

## 常用运维操作

检查 DNS 解析是否正确

```sh
# baidu.com 应解析为直连 ip，如 39.156.66.10
dig baidu.com
# google.com 应解析为 Fake IP，如 198.18.0.4
dig google.com
```

## 缺点

- 仅根据域名白名单进行分流，可能不准确
- 无法支持 Telegram 等应用的固定 IP 访问，需要单独设置路由规则

## ref

[巧用 DNS 实现国内外域名 ip 分流上网](https://blog.lv5.moe/p/use-dns-to-create-split-routing-for-different-domain-or-ip-ranges)
