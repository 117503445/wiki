# SSH

## 公钥登陆

换成自己的公钥

```sh
mkdir -p ~/.ssh && echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYV5Hoaed4dQSmRoZrX+x6p+r16uBHVgv1Zkl8DOMRD 117503445-gen3 >> ~/.ssh/authorized_keys
```

添加 117503445 的公钥 `curl https://wiki.117503445.top/linux/script/ssh.sh | bash`

## 代理

SSH 通过 HTTP / Socks5 代理

安装 openbsd 的 netcat

```sh
pacman -R gnu-netcat --noconfirm
pacman -Sy openbsd-netcat --noconfirm
```

连接

```sh
# 通过 Http 代理访问 SSH
ssh -o ProxyCommand='nc -X connect -x localhost:18080 %h %p' myusername@ssh-server
# 通过 Socks5 代理访问 SSH
ssh -o ProxyCommand='nc -X 5 -x localhost:10028 %h %p' myusername@ssh-server 
# 通过 Socks4 代理访问 SSH
ssh -o ProxyCommand='nc -X 4 -x localhost:10028 %h %p' myusername@ssh-server 
```

写入配置文件 `~/.ssh/config`

```sh
Host myserver 
    HostName  my-ssh-server-ip
    User myusername
    Port 12881
    ProxyCommand nc -X 5 -x localhost:10028 %h %p
```

ref <https://www.inflambda.tech/post/2020-04-07-ssh-proxy.html>
