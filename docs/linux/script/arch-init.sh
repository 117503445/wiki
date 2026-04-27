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
pacman -Syu which zsh fish btop git openssh docker docker-compose docker-buildx nano vim micro base-devel parted tmux python wget yazi go-task go zsh-autosuggestions zsh-syntax-highlighting podman skopeo umoci ncdu cloc fuse-overlayfs nvidia-container-toolkit github-cli jq rsync kubectl helm unzip zip npm --noconfirm
go env -w GOPROXY=https://goproxy.cn,direct

# install yay, https://cloudcone.com/docs/article/how-to-install-yay-helper-on-archlinux/
if [ ! -f /usr/bin/yay ]; then
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

su - builder -c "yay -Su code-server claude-code cursor-cli openai-codex-bin --noconfirm"

npm install @serverless-devs/s -g
wget https://gosspublic.alicdn.com/ossutil/1.7.19/ossutil-v1.7.19-linux-amd64.zip && unzip ossutil-v1.7.19-linux-amd64.zip && mv ossutil-v1.7.19-linux-amd64/ossutil /usr/local/bin/ && rm ossutil-v1.7.19-linux-amd64.zip ossutil-v1.7.19-linux-amd64/ossutil64 && rm -r ossutil-v1.7.19-linux-amd64 || echo "Warning: Failed to download ossutil"

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

chsh -s /usr/bin/zsh
sh -c "$(curl -fsSL https://install.ohmyz.sh)"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
go install github.com/117503445/docker-dev/scripts/shell-init@master && ~/go/bin/shell-init
go install github.com/117503445/docker-dev/scripts/vibe-init@master && ~/go/bin/vibe-init


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

curl https://wiki.117503445.top/linux/script/sysctl-quic.sh | bash

systemctl enable --now cronie.service
systemctl enable --now docker.service
