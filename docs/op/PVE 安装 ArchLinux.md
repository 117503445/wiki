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

// TODO
