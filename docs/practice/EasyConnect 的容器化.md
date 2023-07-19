# EasyConnect 的容器化

## 背景

学校和公司都提供了 VPN 服务。具体的，要在电脑 / 手机上安装 EasyConnect 客户端。

## 现有方案缺点

EasyConnect 是由深信服开发的。一般的使用方式是在每台设备上安装 EasyConnect 客户端，具有以下缺点

- 同一账号同时只能在一台设备上登录，比如在笔记本上登录学校 VPN 账号，台式电脑的 VPN 就会掉线了
- 同一台设备同时只能登录一个账号，比如已经登录了学校的 VPN，访问公司内网就需要进行账号的切换
- 客户端很难用，操作比较奇怪
- 客户端需要管理员权限，根据 <https://taoshu.in/easyconnect-in-docker.html> 所述，会安装证书、干坏事，很不安全

## 容器化方案

通过在固定的服务器上运行 EasyConnect 容器，可以解决上述问题

- EasyConnect 跑在容器里，自己的设备就不需要安装客户端了，比较安全
- 可以在多个设备上同时访问学校和公司的内网，不需要再手动切换代理

首先准备一台可以被其他设备访问的服务器，比如阿里云服务器。

使用 Docker Compose 进行服务的部署，并将 `CLI_OPTS` 中的 `SERVER` `USERNAME` `PASSWORD` 改成自己的账号。

```yaml
version: '3.9'
services:
  easyconnect-school:
    image: hagb/docker-easyconnect:cli
    restart: unless-stopped
    devices:
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    volumes:
      - ./school:/root
    environment:
      - CLI_OPTS=-d SERVER -u USERNAME -p PASSWORD
      - EC_VER=7.6.3
    ports:
      - 21080:1080
    stdin_open: true
    tty: true
  easyconnect-company:
    image: hagb/docker-easyconnect:cli
    restart: unless-stopped
    devices:
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    volumes:
      - ./company:/root
    environment:
      - CLI_OPTS=-d SERVER -u USERNAME -p PASSWORD
      - EC_VER=7.6.3
    ports:
      - 21081:1080
    stdin_open: true
    tty: true
```

使用 socks5 协议，通过 `:21080` 就能访问学校内网，通过 `:21081` 就能访问学校内网。但请确保这些端口只能被自己的设备访问。如果使用阿里云服务器将这些端口暴露在了公网上，那么需要给 socks5 代理密码，请参考 <https://github.com/Hagb/docker-easyconnect/blob/master/doc/usage.md>，设置 `SOCKS_USER` 和 `SOCKS_PASSWD` 的环境变量。

还可以在 Chrome 上使用 SwitchyOmega 拓展，通过设置情景模式，获得丝滑的无缝切换体验。
