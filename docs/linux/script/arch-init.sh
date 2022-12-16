set -ev

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

systemctl enable --now docker.service
systemctl enable --now cronie.service

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

tee ~/.zshrc <<-'EOF'
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM=xterm

DISABLE_UPDATE_PROMPT=true

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="eastwood"

ENABLE_CORRECTION="false"
DISABLE_AUTO_TITLE="true"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    extract
)

# export http_proxy=http://127.0.0.1:1080 && export https_proxy=http://127.0.0.1:1080

source $ZSH/oh-my-zsh.sh

export PATH=/opt/miniconda3/bin:~/.local/bin:~/go/bin:$PATH
export GOPATH=$HOME/go

# export TERMINFO=/usr/share/terminfo # fix conda

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# create .tar
ta() { tar -cvf $1.tar $1; }
# create .tar.gz
targz() { tar -zcvf $1.tar.gz $1; }
# extract .tar
untar() { tar -xvf $1; }
# extract .tar.gz
untargz() { tar -zxvf $1; }
EOF

