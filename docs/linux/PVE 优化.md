# PVE 优化

ArchLinux 在 PVE 中存在 `systemctl daemon-reload` 非常缓慢的问题，经过定位，是 netplan 无法完成执行，1 分钟超时后才会返回。卸载 cloudinit 的 netplan 可以解决这个问题。

```sh
pacman -R netplan --noconfirm

cat>/etc/systemd/network/20-wired.network<<EOF
[Match]
Name=eth0

[Network]
DHCP=ipv4
EOF
```

2024.1.22 更新 此问题已在新版 ArchLinux 中修复，无需再进行上述操作。
