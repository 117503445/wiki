# WSL2 配置

## 序言

WSL2 是在 Windows 上使用 Linux 的技术。相比虚拟机，WSL2 具有以下难以替代的优点

- 支持 CUDA
- 直接对 Windows 的文件进行处理
- 自动内存释放

WSL2 的具体实现是微软魔改出一个 Linux 内核，然后在 Hyper-V 中运行。在复杂的开发过程中，WSL2 还是有玄学的兼容性问题。但是如果使用虚拟机，又很难支持 CUDA。所以建议 AI 相关的环境使用 WSL2，其他开发工作放在虚拟机里。

## 安装

记得要在管理员模式下运行 PowerShell

打开 WSL, Hyper-V, 虚拟机平台 等一系列功能，BIOS 打开 CPU 虚拟化

更新 WSL

```powershell
# https://learn.microsoft.com/en-us/windows/wsl/install
wsl --set-default-version 2
wsl --update

wsl --status # should newest version
```

在 `%UserProfile%\.wslconfig` 写入配置

```ini
[experimental]
autoMemoryReclaim=dropcache # 自动释放内存
sparseVhd=true # 使用稀疏文件
```

安装 Arch WSL

<https://github.com/yuk7/ArchWSL/releases>

如果一直 init key 失败，可以 ctrl c 后 `pacman-key --init && pacman-key --populate`

```powershell
wsl --list
wsl --set-default Arch
```

建议修改配置 `/etc/wsl.conf`

```ini
[boot]
systemd=true

[automount]
enabled = false
options = "metadata"
mountFsTab = false

[interop]
enabled = false
appendWindowsPath = false

[network]
hostname = YOUR_HOSTNAME
```

也可以安装 NixOS

<https://github.com/nix-community/NixOS-WSL>

## CUDA

通过 Geforce 在宿主机安装最新的 NVIDIA 驱动，即可在 WSL 中使用 CUDA

安装 nvidia-container-toolkit 后，即可在 WSL Docker 中使用 CUDA

```sh
pacman -Sy --noconfirm nvidia-container-toolkit
```

验证方法

```sh
docker run --rm -it --gpus=all nvcr.io/nvidia/k8s/cuda-sample:nbody nbody -gpu -benchmark
```

<https://zhuanlan.zhihu.com/p/621142457>

## 防止端口占用

```powershell
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V

netsh int ipv4 set dynamic tcp start=49152 num=16384
netsh int ipv6 set dynamic tcp start=49152 num=16384

dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All
```

<https://www.yuque.com/xiongzichao/blog/yu4i5t>
<https://zhaoji.wang/solve-the-problem-of-windows-10-ports-being-randomly-reserved-occupied-by-hyper-v/>

## 网络模式

WSL 默认的网络模式是 NAT，可以改为 Mirror。但这 2 个都不太行，难以从其他机器直接访问 WSL 的端口。所以最好用的还是 Bridge 模式，给 WSL 分配独立的 IP 地址。

首先确保 WSL 处于关机状态

```powershell
wsl --shutdown
```

参考 [WSL2设置桥接网络及高级设置](http://www.ronnyz.top/2023/11/18/WSL2%E8%AE%BE%E7%BD%AE%E6%A1%A5%E6%8E%A5%E7%BD%91%E7%BB%9C%E5%8F%8A%E9%AB%98%E7%BA%A7%E8%AE%BE%E7%BD%AE/)

Hyper-V 管理器 - 虚拟交换机管理器 - 新建虚拟网络交换机，名称为 bridge，类型为外部网络，并且选择用于上网的网卡。

然后修改 `%UserProfile%\.wslconfig`

```ini
[wsl2]
networkingMode=bridged
vmSwitch=bridge
```

再启动 WSL，就可以发现 WSL 已经有独立的 IP 地址了，而且不用折腾 Windows 上的防火墙。

```powershell
wsl
```

需要注意的是，网桥模式已弃用了，没有官方文档支持。但截至 2025.2.15 的 2.4.11.0 版本，还能用。

## 开机自启

准备 `start-arch.ps1`

```powershell
wsl -d arch bash -c "nohup bash -c 'while true; do sleep 1h; done &' &>/dev/null "
```

然后参考 <https://wiki.117503445.top/windows/%E5%BC%80%E6%9C%BA%E8%87%AA%E5%90%AF/>
