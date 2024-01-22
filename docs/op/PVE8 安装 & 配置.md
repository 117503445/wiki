# PVE8 安装 & 配置

下载 <https://enterprise.proxmox.com/iso/proxmox-ve_8.1-1.iso>, 安装到设备上。

根据 <https://github.com/ventoy/Ventoy/issues/2657>， PVE 8.1-1 与 Ventoy 有冲突，需要使用 Rufus 安装。相信后续的版本会修复这个问题。

## 更换清华源


```
mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat << EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

cat << EOF > /etc/apt/sources.list.d/pve-no-subscription.list
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian/pve bookworm pve-no-subscription
EOF

mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
mv /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak

apt-get update && apt-get upgrade -y
```

## 去除弹窗

```sh
# 执行完成后，浏览器Ctrl+F5强制刷新缓存
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```