# SSH 公钥登陆

换成自己的公钥

``` sh
mkdir -p ~/.ssh && cd ~/.ssh
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYV5Hoaed4dQSmRoZrX+x6p+r16uBHVgv1Zkl8DOMRD 117503445-gen3 >> authorized_keys
```

添加 117503445 的公钥 `curl https://wiki.117503445.top/linux/script/ssh.sh | bash`
