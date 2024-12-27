# QEMU 搭建家庭网络实验环境

## 2024.12.26 Update

如果使用其他网络管理器，如 systemd-networkd，则不要通过 `ip` 命令修改网络端口

对于 systemd-networkd，直接执行以下命令即可

```sh
cat << EOF > /etc/systemd/network/br0.netdev
[NetDev]
Name=br0
Kind=bridge
EOF

cat << EOF > /etc/systemd/network/20-br0.network
[Match]
Name=br0

[Network]
Address=192.168.100.149/24
Gateway=192.168.100.1
EOF

cat << EOF > /etc/systemd/network/10-ens18.network
[Match]
Name=ens18

[Network]
Bridge=br0
EOF

cat << EOF > /etc/systemd/network/br1.netdev
[NetDev]
Name=br1
Kind=bridge
EOF

systemctl reload systemd-networkd
```

## 正文

在测试家庭网络时，如果直接在路由器上搞，可能会影响到家庭网络的正常使用。因此，我们可以使用 QEMU 搭建一个家庭网络实验环境，用于测试家庭网络的各种功能。具体的，本文中会创建 2 个虚拟机，一个作为路由器 `router`，一个作为终端 `guest`，然后通过路由器实现终端访问外网。

宿主机、虚拟机都使用 Arch Linux，文档齐全

网络架构：宿主机所在的网络为 `192.168.100.0/24`。宿主机本来通过 `ens18` 网络接口连接到路由器，路由器的 IP 为 `192.168.100.1`，`ens18` 的 IP 为 `192.168.100.149`

```sh
> ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether bc:24:11:82:21:00 brd ff:ff:ff:ff:ff:ff
    altname enp0s18
    inet 192.168.100.149/24 metric 100 brd 192.168.100.255 scope global dynamic ens18
       valid_lft 43103sec preferred_lft 43103sec
> ip route
default via 192.168.100.1 dev ens18 proto dhcp src 192.168.100.149 metric 100 
192.168.100.0/24 dev ens18 proto kernel scope link src 192.168.100.149 metric 100 
192.168.100.1 dev ens18 proto dhcp scope link src 192.168.100.149 metric 100
```

最终的网络架构：宿主机创建虚拟交换机 `br0` 和 `br1`。宿主机的 `ens18` 会挂载在 `br0` 下；路由器虚拟机的 `eth0` 挂载在 `br0` 下，`eth1` 挂载在 `br1` 下，终端虚拟机的 `eth0` 挂载在 `br1` 下。路由器的 `eth0` 可以申请到 `192.168.100.0/24` 下的 IP，并实现上外网；路由器的 `eth1` 设置 IP 为 `192.168.50.1`；终端的 `eth0` 设置 IP 为 `192.168.50.2`。终端的网络包路径为 终端 `eth0` -> `br1` -> 路由器 `eth1` -> 路由器 `eth0` -> `br0` -> `ens18` -> 外网。

安装 QEMU 依赖

```sh
pacman -Syu --noconfirm qemu
```

安装 NoVNC，用于在 Web 中查看虚拟机的图形界面

```sh
# 只要不在 root 用户下运行 yay 就行
su - builder -c "yay -Sy --noconfirm novnc"
```

安装 aria2，用于多线程下载镜像

```sh
pacman -Syu --noconfirm aria2
```

创建 `br0`，ref <https://wiki.archlinux.org/title/Network_bridge#Adding_the_main_network_interface_2>

```sh
cat << EOF > ./bridge.sh
ip link add name br0 type bridge
ip link set dev br0 up
ip address add 192.168.100.149/24 dev br0
ip route append default via 192.168.100.1 dev br0
ip link set ens18 master br0
ip address del 192.168.100.149/24 dev ens18
EOF
chmod +x ./bridge.sh
./bridge.sh
```

查看 `br0` 的信息

```sh
> ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether bc:24:11:82:21:00 brd ff:ff:ff:ff:ff:ff
    altname enp0s18
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:ad:03:b2:41 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 4a:08:ce:53:1b:53 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.149/24 scope global br0
       valid_lft forever preferred_lft forever
> ip route
default via 192.168.100.1 dev br0 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
192.168.100.0/24 dev br0 proto kernel scope link src 192.168.100.149
> bridge link
2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100
```

创建 `br1`

```sh
ip link add name br1 type bridge
ip link set dev br1 up
```

允许 QEMU 使用 `br0` 和 `br1`

```sh
cat << EOF > /etc/qemu/bridge.conf
allow br0
allow br1
EOF
```

下载 ArchLinux qcow2 镜像

```sh
aria2c -x 16 -s 16 https://geo.mirror.pkgbuild.com/images/v20241115.279641/Arch-Linux-x86_64-basic-20241115.279641.qcow2
```

准备虚拟机镜像

```sh
cp Arch-Linux-x86_64-basic-20241115.279641.qcow2 router.qcow2
cp Arch-Linux-x86_64-basic-20241115.279641.qcow2 guest.qcow2
```

运行 `router` 虚拟机, `-enable-kvm` 启用 KVM 加速，`-m 4096M` 指定 4096M 内存

```sh
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096M \
  -hda router.qcow2 \
  -nic bridge,br=br0,model=virtio-net-pci \
  -nic bridge,br=br1,model=virtio-net-pci
```

输出 `VNC server running on ::1:5900`，运行 NoVNC

```sh
novnc --vnc localhost:5900 --listen 6080
```

然后就可以在浏览器中访问 `http://192.168.100.149:6080/vnc.html` 查看虚拟机的图形界面了。

运行 `guest` 虚拟机。手动指定 `guest` 虚拟机的 mac，防止冲突。

```sh
qemu-system-x86_64 \
  -enable-kvm \
  -m 4096M \
  -hda guest.qcow2 \
  -nic bridge,br=br1,model=virtio-net-pci,mac=52:54:98:76:54:32
```

输出 `VNC server running on ::1:5901`，运行 NoVNC

```sh
novnc --vnc localhost:5901 --listen 6081
```

然后就可以在浏览器中访问 `http://192.168.100.149:6081/vnc.html` 查看虚拟机的图形界面了。

在 2 个虚拟机中，都进行些初始化操作

```sh
# 用户名 密码 都是 arch
sudo su # 切换到 root 用户
cd ~ # 切换到用户目录
```

查看相关信息

```sh
ip a
ip route
ip neighbor
```

`router` 虚拟机输出如下

![alt text](<QEMU 搭建家庭网络实验环境.assets/image.png>)

`guest` 虚拟机输出如下

![alt text](<QEMU 搭建家庭网络实验环境.assets/image-1.png>)

可以看到，`router` 虚拟机的 `eth0` 申请到了 `192.168.100.111`，已经可以上网了

启用 SSH

```sh
systemctl is-system-running # 预期 running，如果还是 starting，可以 systemctl list-jobs 查看任务，并 systemctl stop 卡住的任务
systemctl enable --now sshd # 启用 sshd 服务
```

启用 SSH 后，可以通过 `ssh arch@192.168.100.111` 登录到 `router` 虚拟机，再 `sudo su` 切到 `root` 用户。但 `guest` 还没联网，所以暂时还只能用 `NoVNC`。


在 `router` 虚拟机中 修改网络转发配置
```sh
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.forwarding=1
sysctl -w net.ipv6.conf.all.forwarding=1
```

检查网络转发配置

```sh
cat /proc/sys/net/ipv4/ip_forward
# 预期输出 1
```

在 `router` 虚拟机中 添加 eth1 静态 ip 配置

```sh
ip address add 192.168.50.1/24 dev eth1
```

检查

```sh
> ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    altname ens3
    inet 192.168.100.111/24 metric 1024 brd 192.168.100.255 scope global dynamic eth0
       valid_lft 43143sec preferred_lft 43143sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff
    altname enp0s4
    altname ens4
    inet 192.168.50.1/24 brd 192.168.50.255 scope global eth1
       valid_lft forever preferred_lft forever
```

在 `guest` 上设置静态 ip

```sh
ip address add 192.168.50.2/24 dev eth0
ip route add default via 192.168.50.1 dev eth0
```

现在 `guest` 已经可以访问 `router` 了，但无法访问 外网

![alt text](<QEMU 搭建家庭网络实验环境.assets/image-3.png>)

再在 `router` 上启用 NAT, ref <https://wiki.archlinux.org/title/Internet_sharing#Enable_packet_forwarding>

```sh
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

`guest` 上可以访问外网啦

![alt text](<QEMU 搭建家庭网络实验环境.assets/image-2.png>)

但需注意的是，这只是搭建了最简单的实验环境，很多配置都没有做持久化。还有就是 Arch 默认使用 systemd-networkd 管理网络，静态设置接口 IP 可能与之产生冲突。
