# PVE 安装 NixOS

## 创建虚拟机

下载 [Minimal ISO image](https://nixos.org/download.html), 上传到 PVE

创建虚拟机时启用 UEFI，但是要取消 `系统 - 预注册密钥`

进入 CD 系统

切换到 root 账户

```sh
sudo -i
passwd # 修改密码
ip a # 获取 ip
```

通过 SSH 连接，进行后续操作

```sh
ssh root@host
```

## 分区及安装

如果要使用 ext4 分区，运行以下命令

```sh
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MB -8GB
parted /dev/sda -- mkpart primary linux-swap -8GB 100%
parted /dev/sda -- mkpart ESP fat32 1MB 512MB
parted /dev/sda -- set 3 esp on
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
nixos-generate-config --root /mnt
nixos-install
```

如果要使用 btrfs 分区，运行以下命令

```sh
printf "label: gpt\n,550M,U\n,,L\n" | sfdisk /dev/sda
mkfs.fat -F 32 /dev/sda1
mkfs.btrfs /dev/sda2
mkdir -p /mnt
mount /dev/sda2 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
umount /mnt
mount -o compress=zstd,subvol=root /dev/sda2 /mnt
mkdir /mnt/{home,nix}
mount -o compress=zstd,subvol=home /dev/sda2 /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/sda2 /mnt/nix
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
nixos-generate-config --root /mnt
nixos-install
```

输入密码并重启

## 配置

修改

```sh
nano /etc/nixos/configuration.nix
```

在合适的位置进行修改

```plaintext
# 启用 SSH
services.openssh.enable = true;
services.openssh.settings.PermitRootLogin = "yes";

environment.systemPackages = with pkgs; [
    wget
    git # 安装 git
];

programs.nix-ld.enable = true; # 允许 VSCode Remote
```

切换配置

```sh
nixos-rebuild switch
```

然后上传自己的配置文件，进行切换

```sh
nixos-rebuild switch --flake .#nixos-dev
```

在 VS Code 中，还可以指定主机使用 fish 终端

```json
{
    "terminal.integrated.profiles.linux": {
      "fish": {
        "path": "fish",
      }
    },
    "terminal.integrated.defaultProfile.linux": "fish"
}
```
