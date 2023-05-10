# ArchLinux DNS

使用比较暴力的方式修改 ArchLinux DNS

```sh
rm /etc/resolv.conf
cat << EOF > /etc/resolv.conf
nameserver 223.5.5.5
EOF
chattr +i /etc/resolv.conf # 禁止修改
```
