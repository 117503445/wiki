set -e

curl https://wiki.117503445.top/linux/script/ssh.sh | bash

timedatectl set-timezone Asia/Shanghai

cat>/etc/pacman.d/mirrorlist<<EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
EOF

pacman -Sy archlinux-keyring --noconfirm
pacman -Syyu --noconfirm
pacman -S which zsh btop git docker docker-compose cronie nano vim micro net-tools dnsutils inetutils iproute2 traceroute --noconfirm

cat>>/etc/pacman.conf<<EOF
[archlinuxcn]
Server = https://repo.archlinuxcn.org/\$arch
EOF

pacman -Syu archlinuxcn-keyring --noconfirm
pacman -S base-devel --noconfirm
pacman -S yay --noconfirm

systemctl enable docker.service
systemctl enable cronie.service

chsh -s $(which zsh)

reboot