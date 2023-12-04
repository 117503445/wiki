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

pacman -Sy archlinux-keyring --noconfirm
pacman -Syyu --noconfirm
pacman -S which wget zsh fish btop git docker docker-buildx cronie nano vim micro net-tools dnsutils inetutils iproute2 traceroute parted btrfs-progs tmux tldr openssh --noconfirm

cat>>/etc/pacman.conf<<EOF
[archlinuxcn]
Server = https://repo.archlinuxcn.org/\$arch
EOF

pacman -Syu archlinuxcn-keyring --noconfirm
pacman -S base-devel --noconfirm
pacman -S yay --noconfirm

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

chsh -s /usr/bin/fish
mkdir -p ~/.config/fish
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
    function ta
        tar -cvf \$argv[1].tar \$argv[1]
    end
    function targz
        tar -zcvf \$argv[1].tar.gz \$argv[1]
    end
    function untar
        tar -xvf \$argv[1]
    end
    function untargz
        tar -zxvf \$argv[1]
    end
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
    pacman -S qemu-guest-agent --noconfirm
    cat>>/usr/lib/systemd/system/qemu-guest-agent.service<<EOF
WantedBy=multi-user.target
EOF
    systemctl enable --now qemu-guest-agent
fi

systemctl enable --now cronie.service
systemctl enable --now docker.service