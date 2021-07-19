# Git Clone 加速

## --depth=1

如果不需要历史记录，可以加上这一条，只下载最新的文件。

`git clone --depth=1 https://github.com/offensive-security/exploitdb.git`

## cnpmjs.org

对于 Github，cnpmjs.org 提供了加速服务，可以在国内非常快的进行下载。

`git clone --depth=1 https://github.com.cnpmjs.org/offensive-security/exploitdb.git`

## Proxy

设置代理是最吼的。

```sh
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
```
