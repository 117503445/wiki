set -e

curl https://wiki.117503445.top/linux/script/ssh.sh | bash

timedatectl set-timezone Asia/Shanghai

cat>/etc/pacman.d/mirrorlist<<EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
EOF

pacman -S archlinux-keyring --noconfirm
pacman -Syyu --noconfirm
pacman -S which zsh btop git docker docker-compose cronie nano vim micro --noconfirm

systemctl enable docker.service
systemctl enable cronie.service

# pacman -S net-tools dnsutils inetutils iproute2 --noconfirm

chsh -s $(which zsh)

# sudo gpasswd -a ${USER} docker

reboot