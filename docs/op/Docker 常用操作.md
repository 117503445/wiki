# Docker 常用操作

## 镜像源 及 日志设置

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://990v82t8.mirror.aliyuncs.com"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1m",
    "max-file": "1"
  }
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

镜像源使用了中科大的，实际会被重定向到阿里云的公共镜像加速服务。

日志设置为 每个容器最多只有 1 个 1MB 的日志文件，防止海量日志将磁盘占满。

## Docker Machine 安装 + 远程访问

- 本机安装 docker-machine 工具
- 完成公钥登录，本地私钥存在 ~/.ssh/id_rsa
- 本地执行

```bash
docker-machine create --driver generic --generic-ip-address=${ip} --generic-ssh-key ~/.ssh/id_rsa --engine-registry-mirror https://${Your}.mirror.aliyuncs.com ${name}
```

## 创建 网络

`docker network create traefik`

## 调试镜像

构建 container 失败的时候，无法查看文件，会造成调试的困难。

这时候可以在 docker run 中手动指定入口点。

```bash
docker build -t debuger .
docker run -it --entrypoint /bin/sh debuger
```

## 开启远程访问

在 8888 端口开启了远程访问，因为没有加密，保证机子被挂上挖矿⛏脚本。

```sh
echo "[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=8888
BindIPv6Only=both
Service=docker.service

[Install]
WantedBy=sockets.target" > /etc/systemd/system/docker-tcp.socket
systemctl enable docker-tcp.socket
systemctl stop docker
systemctl start docker-tcp.socket
systemctl start docker
```

如果确实有远程访问的要求，建议用 Docker Machine 创建加密的远程访问。

目前体验下来，建议不要开启远程访问，可以使用 VS Code Remote 进行 Docker 相关操作。

## 打印 Docker 容器 ip

ref <https://blog.csdn.net/sannerlittle/article/details/77063800>

`docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress }}' $(docker ps -aq)`

## docker run -it 在 docker-compose 中的写法

ref <https://stackoverflow.com/questions/36249744/interactive-shell-using-docker-compose>

```yaml
version: "3.9"
services:
  app:
    image: app:1.2.3
    stdin_open: true # docker run -i
    tty: true        # docker run -t
```

## 查询容器状态

`docker stats`

## 同步宿主机时间

```yaml
volumes:
  - /etc/localtime:/etc/localtime:ro
  - /etc/timezone:/etc/timezone:ro
```

## docker-compose 拉取最新镜像并运行

```sh
docker compose pull && docker compose up -d
```
