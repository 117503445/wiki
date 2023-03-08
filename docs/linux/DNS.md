# DNS

修改 DNS 并防止被其他网络管理器覆写

```sh
echo "nameserver 223.5.5.5" > /etc/resolv.conf
chattr +i /etc/resolv.conf
```
