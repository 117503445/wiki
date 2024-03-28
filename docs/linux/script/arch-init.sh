#!/usr/bin/env bash
set -ev

if [[ -f /var/lib/pacman/db.lck ]]; then
    echo "Pacman database is locked. You could remove /var/lib/pacman/db.lck to continue install."
    exit 1
fi

curl https://wiki.117503445.top/linux/script/ssh.sh | bash

timedatectl set-timezone Asia/Shanghai

cat>/etc/timezone<<EOF
Asia/Shanghai
EOF

cat>/etc/pacman.d/mirrorlist<<EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
EOF

pacman-key --init && pacman-key --populate
pacman -Sy archlinux-keyring --needed --noconfirm && pacman -Su --needed --noconfirm
pacman -S which wget zsh fish btop git docker docker-compose docker-buildx cronie nano vim micro net-tools dnsutils inetutils iproute2 traceroute parted btrfs-progs tmux tldr openssh rsync --needed --noconfirm


# install yay, https://cloudcone.com/docs/article/how-to-install-yay-helper-on-archlinux/
if [ ! -f /usr/bin/yay ]; then
    pacman -Sy base-devel --needed --noconfirm
    mkdir -p /tmp/yay-build
    useradd -m -G wheel builder && passwd -d builder
    chown -R builder:builder /tmp/yay-build
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    if [ ! -d /tmp/yay-build/yay ]; then
        su - builder -c "git clone https://aur.archlinux.org/yay.git /tmp/yay-build/yay"
    fi
    su - builder -c "export GOPROXY=https://goproxy.cn && cd /tmp/yay-build/yay && makepkg -si --noconfirm"
    rm -rf /tmp/yay-build
fi

if [ ! -f /etc/docker/daemon.json ]; then
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
"log-driver": "json-file",
"log-opts": {
    "max-size": "1m",
    "max-file": "1"
}
}
EOF
fi

chsh -s /usr/bin/fish

mkdir -p ~/.config/fish
touch ~/.config/fish/node.fish
cat << EOF > ~/.config/fish/config.fish
if status is-interactive
    set fish_greeting # Disable greeting

    # set -x all_proxy "socks5://127.0.0.1:1080"; set -x http_proxy \$all_proxy; set -x https_proxy \$all_proxy

    set -x PATH ~/.local/bin ~/go/bin \$PATH
    
    alias dc="docker compose"
    alias dcu="dc up -d"
    alias dcd="dc down"
    alias dcl="dc logs -f"
    alias dcp="dc pull"
    alias dcr="dc restart"
    alias dc-update="dcp && dcu"
    alias upd="pacman -Sy archlinux-keyring --needed --noconfirm && pacman -Su --noconfirm"
    function ta
        set source \$argv[1]
        set target (basename \$source)".tar"
        tar -cvf \$target \$source
    end
    function targz
        set source \$argv[1]
        set target (basename \$source)".tar.gz"
        tar -zcvf \$target \$source
    end
    function untar
        set source \$argv[1]
        tar -xvf \$source
    end
    function untargz
        set source \$argv[1]
        tar -zxvf \$source
    end
    source ~/.config/fish/node.fish
end
EOF

# cat>>/etc/environment<<EOF
# LANG=en_US.utf-8
# LC_ALL=en_US.utf-8
# EOF

git config --global user.name "117503445"
git config --global user.email t117503445@gmail.com
# https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault
git config --global push.default current # push the current branch to a branch of the same name
git config --global core.editor "code --wait" # VS Code
git config --global init.defaultBranch master


if [ -e /dev/virtio-ports/org.qemu.guest_agent.0 ]; then
    echo "/dev/virtio-ports/org.qemu.guest_agent.0 exists"
    pacman -Su qemu-guest-agent --needed --noconfirm
    if ! grep -q "WantedBy" /usr/lib/systemd/system/qemu-guest-agent.service; then
        echo "WantedBy=multi-user.target" >> /usr/lib/systemd/system/qemu-guest-agent.service
    fi
    systemctl enable --now qemu-guest-agent
fi

systemctl enable --now cronie.service
systemctl enable --now docker.service
