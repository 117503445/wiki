# PVE 安装 ArchLinux

## ISO

普通的安装模式

下载 ISO 镜像 <https://geo.mirror.pkgbuild.com/iso/latest/>，导入 local 储存

1. 创建虚拟机
2. 常规 - 开机自启动
3. 操作系统 - 选择 ISO 镜像
4. 系统 - Qemu 代理，BIOS - OVMF (UEFI)，EFI 储存 - local-lvm，取消勾选预注册密钥
5. 硬盘 - 改变磁盘大小，如果是 SSD 硬盘则勾选 SSD 仿真、丢弃(Trim)
6. CPU - 类别 host，修改插槽、核心数
7. 内存 - 修改内存大小
8. 网络 - 不变

进入系统后，使用 archinstall 进行安装

## Cloud-init

ref [在 Proxmox VE pve 里使用 cloud-init 构建（centos\ubuntu\debian）cloud images | 佛西博客](https://foxi.buduanwang.vip/virtualization/pve/388.html/) [Cloud-init 使用](https://otkyd4jmkr.feishu.cn/wiki/wikcneGcizXquLGvLXGPceATxdf)

![](./PVE 安装 ArchLinux.assets/VyLCbCF5coLQJaxRISxchI7mn8e.png)

![](./PVE 安装 ArchLinux.assets/P1ISbCWFpoyVihxB8vec91U6n44.png)

![](./PVE 安装 ArchLinux.assets/Dfaibwx6XoZvgZxCnPgc2FKinPg.png)

![](./PVE 安装 ArchLinux.assets/UEgqbNWxnoZuZ6xK1tScijURnIc.png)

![](./PVE 安装 ArchLinux.assets/IWutbwENvo7mJvxbE2tc9nWVnEf.png)

![](./PVE 安装 ArchLinux.assets/RlClb2A0VoWDNCxpbqHcot7sn0e.png)

![](./PVE 安装 ArchLinux.assets/SAGJbJEG4okl03xgiVacRlhhnid.png)

![](./PVE 安装 ArchLinux.assets/HpJ2bdRQjo0SdExvdxqcu3Ednuc.png)

![](./PVE 安装 ArchLinux.assets/BLpgbFyRXoS84VxGtlIcp15fnff.png)

![](./PVE 安装 ArchLinux.assets/TQQsbsJ0boTQ4wx1PQ0cwiErnth.png)

![](./PVE 安装 ArchLinux.assets/MRUVb7jjaoIsq8xKSHEcJQ3fnnc.png)

![](./PVE 安装 ArchLinux.assets/GFJIbHMrOocEWSxmodZc9Knqnph.png)

![](./PVE 安装 ArchLinux.assets/XtJDb1D75oDwt3x8hdicfvoznZf.png)

![](./PVE 安装 ArchLinux.assets/KM3QboSpwon49kxdEXncNRRenIc.png)

![](./PVE 安装 ArchLinux.assets/I170bElnsoEnDbxXFxGcD9nTnQb.png)

![](./PVE 安装 ArchLinux.assets/AJowbktWXopvVqxhLCUcLRDwnfb.png)

![](./PVE 安装 ArchLinux.assets/OP3KbMKXVoDN7DxaToUcqdpKn8d.png)

![](./PVE 安装 ArchLinux.assets/Wpr7btCy1oTaOWxsfIKc2qibn0f.png)

![](./PVE 安装 ArchLinux.assets/Iru6bn7tpoHsnYx0SvFc7itGnxb.png)

完成添加

![](./PVE 安装 ArchLinux.assets/S8LkbhtnnopZkzxlzgfcHVMqnPc.png)

![](./PVE 安装 ArchLinux.assets/ADzlbI3DxoO4dKx45Rlc1qsgn6e.png)

```apache
cd /var/lib/vz/images
qm importdisk 108 CentOS-7-x86_64-GenericCloud-2009.qcow2 nvme-data --format=qcow2
qm importdisk 110 ubuntu-22.04-server-cloudimg-amd64.img nvme-data
qm importdisk 113 k3os-amd64.iso nvme-data

qm importdisk 106 Arch-Linux-x86_64-cloudimg-20230301.130409.qcow2 local-lvm
```

108 表示新建虚拟机的编号

CentOS-7-x86_64-GenericCloud-2009.qcow2 为镜像名

NVME 为储存池名

Cloud-init 镜像下载路径 [在 Proxmox VE pve 里使用 cloud-init 构建（centos\ubuntu\debian）cloud images | 佛西博客](https://foxi.buduanwang.vip/virtualization/pve/388.html/)

ArchLinux 在 [https://geo.mirror.pkgbuild.com/images/](https://geo.mirror.pkgbuild.com/images/)

![](./PVE 安装 ArchLinux.assets/W1B2bb7jyouYThxNl4aceWfynbg.png)

![](./PVE 安装 ArchLinux.assets/MrYtbgHfloKCKpx6D98cObaWnqh.png)

![](./PVE 安装 ArchLinux.assets/MVrxbBMRWo2i7zxmMpHc9Dj7nEc.png)

Ip 设置，可以是 DHCP，然后去 openwrt 找 分配到的 ip

也可以直接静态设置 ip

![](./PVE 安装 ArchLinux.assets/ZtYRb6e8koCu9kx2eGKcaT5wndf.png)

![](./PVE 安装 ArchLinux.assets/EPKEbfzToo3LNoxmckUc3FN5nhe.png)

![](./PVE 安装 ArchLinux.assets/SZWibwehfoGusPxE6w8cU0Xznbh.png)

然后也可以将这个虚拟机转换成模板，批量进行创建

![](./PVE 安装 ArchLinux.assets/BB8vbnbn3oCn3uxWV3icd3tZnAb.png)

![](./PVE 安装 ArchLinux.assets/GWajbmxTZoPj7CxvdVpcCLXNnQc.png)

![](./PVE 安装 ArchLinux.assets/X4VWb6ebfoRlKtxblBEcvXNSn9g.png)
