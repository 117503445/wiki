# OpenWrt 软路由

我家中的网络架构是 光猫 - 软路由 - 交换机 - 各无线路由器(AP)

其中软路由起到了至关重要的作用，拨号、DHCP 等

我使用的是 友善 NanoPi R2S。之前已经连续稳定运行了 400 天，但是存在以下问题

- 使用了出厂的 OpenWrt 整合包，预装了一大堆软件，容易存在功能冲突，不敢动
- 内核是修改过的，导致无法安装 tailscale 进行组网

于是本次重新安装了 OpenWrt，并以此文叙述安装过程

首先去设备官网 <https://openwrt.org/toh/friendlyarm/nanopi_r2s> 寻找下载链接

看到有 2 种镜像 `ext4-sysupgrade.img.gz` `squashfs-sysupgrade.img.gz`

这 2 种镜像的区别在于系统的文件系统。`squashfs` 的系统分区是只读的，修改通过 overlay 进行。因此，`squashfs` 支持重置功能，可以将系统恢复到安装时的状态。`ext4` 则比较普通，和正常电脑差不多，也不支持重置。

我选择了 `ext4`

因为原系统已经是 OpenWrt 了，所以我直接把镜像丢进 <http://ROUTE/cgi-bin/luci/admin/system/flash> 进行固件刷写即可。

一开始我选择保留数据和配置，然后发现 SSH 一连上就断。最后定位到是遗留配置的锅，然后再刷了一遍系统。

默认的子网是 `192.168.1.0/24`。但是如果要打通多个家的内网，IP 就很容易冲突。所以建议改成 `192.168.50.0/24` 之类的。

配置 opkg

```sh
sed -i 's_downloads.openwrt.org_mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg/distfeeds.conf
opkg update
opkg install luci-i18n-base-zh-cn
opkg install arp-scan arp-scan-database
```

然后是分区扩容。SD 卡有 8G，但是系统分区只有 100m。主要参考了 <https://www.jianshu.com/p/e83459242afb>

```sh
opkg install fdisk cfdisk resize2fs block-mount 
```

重启，确定 luci 中已经出现了挂载点的页面

首先通过 `cfdisk` 把 SD 卡剩余的空间建区，名字是 `/dev/mmcblk0p3`

```sh
mkfs.ext4 /dev/mmcblk0p3 # format

# 把系统拷贝到 /dev/mmcblk0p3
cd /
mkdir -p /tmp/introot
mkdir -p /tmp/extroot
mount --bind / /tmp/introot
mount /dev/mmcblk0p3 /tmp/extroot
tar -C /tmp/introot -cvf - . | tar -C /tmp/extroot -xf -
umount /tmp/introot
umount /tmp/extroot
```

然后在 luci 的挂载点界面中，勾选 `/dev/mmcblk0p3` 分区为 root 挂载点。

重启，然后就会发现扩容成功了。

安装 Tailscale

```sh
opkg install tailscale
service tailscale start
tailscale up --advertise-routes=192.168.50.0/24 --login-server=$LOGIN_SERVER  --accept-routes=true --accept-dns=false
```

安装 OpenClash

要注意 dnsmasq 的卸载和 dnsmasq-full 的安装一定要在同一行命令中进行，不然就会出现上不了网导致无法安装 dnsmasq-full 的尴尬局面。

```sh
opkg update
opkg remove dnsmasq && opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
```

Enjoy :)
