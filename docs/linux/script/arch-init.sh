set -ev

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
pacman -S which wget zsh btop git docker docker-compose cronie nano vim micro net-tools dnsutils inetutils iproute2 traceroute parted btrfs-progs tmux --noconfirm

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

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cat>>/etc/environment<<EOF
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

tee ~/.zshrc <<-'EOF'
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

alias dc="docker compose"
alias dcu="dc up -d"
alias dcd="dc down"
alias dcl="dc logs"
alias dcp="dc pull"
alias "dc-update"="dcp && dcu"
EOF

git config --global user.name "117503445"
git config --global user.email t117503445@gmail.com
# https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushdefault
git config --global push.default current # push the current branch to a branch of the same name
git config --global core.editor "code --wait" # VS Code

systemctl enable --now cronie.service
systemctl enable --now docker.service