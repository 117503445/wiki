# Wireguard VPN

ref <https://blog.alanwei.com/blog/2021/03/04/mac-install-wireguard/>

## install

`brew install wireguard-tools`

## 配置文件

```sh
sudo mkdir /usr/local/etc/wireguard
sudo touch /usr/local/etc/wireguard/wg0.conf
```

## 操作

```sh
sudo wg-quick up wg0 # 启动 wg0 配置文件 对应的连接
sudo wg-quick down wg0 # 关闭 wg0 配置文件 对应的连接
sudo wg show # 显示信息
```
