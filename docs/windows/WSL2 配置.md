# WSL2 配置

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
[wsl2]
memory=96GB

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
```

安装 Arch WSL

<https://github.com/yuk7/ArchWSL/releases>

如果一直 init key 失败，可以 ctrl c 后 `pacman-key --init && pacman-key --populate`

```powershell
wsl --list
wsl --set-default Arch
```

建议修改配置 `/etc/wsl.conf` 防止影响 Windows 系统

```ini
[interop]
enabled = false
appendWindowsPath = false
```

也可以安装 NixOS

<https://github.com/nix-community/NixOS-WSL>

## CUDA

通过 Geforce 在宿主机安装最新的 NVIDIA 驱动，即可在 WSL 中使用 CUDA

安装 [nvidia-container-toolkit](https://aur.archlinux.org/packages/nvidia-container-toolkit) 后，即可在 WSL Docker 中使用 CUDA

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

## Docker 暴露端口

2024.2.14 update: 别用这个方法，会导致 Docker 容器无法上网。建议在 <https://github.com/microsoft/WSL/issues/10494> 修复前，先用 HOST 网络模式。

在 WSL2 镜像网络模式下，Windows 无法连接 Docker 容器的端口

在 /etc/docker/daemon.json 中写入

```json
{
    "iptables": false
}
```

ref <https://www.sulinehk.com/post/fix-docker-connection-issues-in-wsl2-mirrored-networking-mode/>

## 开机自启

准备 `start-arch.ps1`

```powershell
wsl -d arch bash -c "nohup bash -c 'while true; do sleep 1h; done &' &>/dev/null "
```

然后参考 <https://wiki.117503445.top/windows/%E5%BC%80%E6%9C%BA%E8%87%AA%E5%90%AF/>
