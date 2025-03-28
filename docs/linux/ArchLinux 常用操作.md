# ArchLinux 常用操作

## archinstall 安装

```sh
systemctl is-system-running # 预期 running，否则检查网络或者其他问题

# 2024.8.11 systemd-userdbd 经常卡住，直接干掉就行
systemctl stop systemd-userdbd

# archinstall 可能不会覆盖原有的 mirror，导致最后使用了错误的 mirror
systemctl mask reflector.service
systemctl stop reflector.service
cat>/etc/pacman.d/mirrorlist<<EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
EOF

archinstall --config https://wiki.117503445.top/linux/script/user_configuration.json --creds https://wiki.117503445.top/linux/script/user_credentials.json --skip-version-check
```

然后修改 主机名、硬盘分区、用户密码

在 chroot 的新系统中安装 SSH 密钥

```sh
curl https://wiki.117503445.top/linux/script/ssh.sh | bash

# or 替换为自己的公钥

mkdir -p ~/.ssh && echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYV5Hoaed4dQSmRoZrX+x6p+r16uBHVgv1Zkl8DOMRD 117503445-gen3 >> ~/.ssh/authorized_keys
```

## 已有系统初始化

`curl https://wiki.117503445.top/linux/script/arch-init.sh | bash`

<https://wiki.117503445.top/linux/script/arch-init.sh>

## 更新

```sh
# https://wiki.archlinux.org/title/Pacman/Package_signing
pacman -Sy archlinux-keyring --needed --noconfirm && pacman -Su --noconfirm
```

签名出错时，可以删除 `gnupg` 后重试

```sh
rm -rf /etc/pacman.d/gnupg
```

ref <https://razonyang.com/zh-hans/blog/archlinux/reset-keyring/>

## Swap 分区

```sh
# not for Btrfs
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress
chmod 0600 /swapfile
mkswap -U clear /swapfile
swapon /swapfile

echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

ref <https://wiki.archlinuxcn.org/wiki/Swap>

## 云服务器安装

2023.01.18 阿里云 ECS 实践通过
2023.05.12 腾讯云 轻量应用服务器 实践通过

### 云服务器安装 ubuntu 18.04

### 修改 root 密码

### 执行脚本

```sh
wget https://felixc.at/vps2arch && chmod +x vps2arch
./vps2arch -m https://mirrors.ustc.edu.cn/archlinux/
```

### 重启

通过 VNC 执行 `reboot -f`

## Emoji 显示修复

在 ArchLinux 下，Emoji 往往会显示成乱码，通过修改 Fontconfig 可以解决这个问题。

首先安装 noto-fonts-emoji 字体

`sudo pacman -S noto-fonts-emoji`

然后修改 Fontconfig

```sh
sudo su
mkdir -p /etc/fonts/conf.avail
cat>/etc/fonts/conf.avail/75-noto-color-emoji.conf<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <!-- Add generic family. -->
    <match target="pattern">
        <test qual="any" name="family"><string>emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <!-- This adds Noto Color Emoji as a final fallback font for the default font families. -->
    <match target="pattern">
        <test name="family"><string>sans</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>serif</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>sans-serif</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test name="family"><string>monospace</string></test>
        <edit name="family" mode="append"><string>Noto Color Emoji</string></edit>
    </match>

    <!-- Block Symbola from the list of fallback fonts. -->
    <selectfont>
        <rejectfont>
            <pattern>
                <patelt name="family">
                    <string>Symbola</string>
                </patelt>
            </pattern>
        </rejectfont>
    </selectfont>

    <!-- Use Noto Color Emoji when other popular fonts are being specifically requested. -->
    <match target="pattern">
        <test qual="any" name="family"><string>Apple Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Segoe UI Symbol</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Android Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twitter Color Emoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twemoji</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Twemoji Mozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>TwemojiMozilla</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiTwo</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Emoji Two</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>EmojiSymbols</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family"><string>Symbola</string></test>
        <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
    </match>

</fontconfig>
EOF

ln -sf /etc/fonts/conf.avail/75-noto-color-emoji.conf /etc/fonts/conf.d/
```

然后可以前往 <https://github.com/13rac1/emojione-color-font/blob/master/full-demo.html> 测试 Emoji 是否显示正确。

ref <https://ld246.com/article/1581074244078>
