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
[boot]
systemd=true

[interop]
enabled=false
appendWindowsPath=false

[wsl2]
memory=48g

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

