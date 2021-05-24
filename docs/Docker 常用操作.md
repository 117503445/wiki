# Docker 常用操作

## 阿里镜像源 及 日志设置

每个人都有自己的加速地址，记得申请后进行替换。

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://${Your}.mirror.aliyuncs.com"],
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

日志设置为 每个容器最多只有 1 个 1MB 的日志文件，防止海量日志将磁盘占满。

## Docker Machine 安装 + 远程访问

1. 本机安装 docker-machine 工具
1. 完成公钥登录，本地私钥存在 ~/.ssh/id_rsa
1. 本地执行

```bash
docker-machine create --driver generic --generic-ip-address=${ip} --generic-ssh-key ~/.ssh/id_rsa --engine-registry-mirror https://${Your}.mirror.aliyuncs.com ${name}
```

## 创建 网络

`docker network create treafik-proxy`

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

如果确实有远程访问的要求，建议用 docker machine 创建加密的远程访问。

目前体验下来 VS Code 的 Remote 最好。
