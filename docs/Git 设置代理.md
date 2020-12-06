# Git 设置代理

Git 不会默认走系统代理,需要手动设置代理

```sh
git config --global http.proxy 'socks5://127.0.0.1:2080'
git config --global https.proxy 'socks5://127.0.0.1:2080'
```

其中代理服务器的路径要结合本机具体情况。
