# Docker 常用操作

## 日志设置

```bash
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1m",
    "max-file": "1"
  }
}
EOF
systemctl daemon-reload
systemctl restart docker
```

没有设置 registry-mirrors。因为阿里云的服务已经停止更新，拉取 latest 时会拉到旧的镜像，产生很大的困扰。

日志设置为 每个容器最多只有 1 个 1MB 的日志文件，防止海量日志将磁盘占满。

## 拉取代理设置

ref <https://www.lfhacks.com/tech/pull-docker-images-behind-proxy/>

```sh
mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:1080"
Environment="HTTPS_PROXY=http://127.0.0.1:1080"
EOF
systemctl daemon-reload
systemctl restart docker
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
