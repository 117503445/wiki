# QEMU Guest Agent

QEMU Guest Agent 是运行在虚拟机中的代理，PVE 通过此代理可以显示虚拟机的 IP 信息。

## Install

### ArchLinux

```sh
pacman -S qemu-guest-agent --noconfirm
cat>/usr/lib/systemd/system/qemu-guest-agent.service<<EOF
WantedBy=multi-user.target
EOF
systemctl enable --now qemu-guest-agent
```

### Ubuntu

```sh
apt update && apt -y install qemu-guest-agent
systemctl enable --now qemu-guest-agent
```

### CentOS

自带
