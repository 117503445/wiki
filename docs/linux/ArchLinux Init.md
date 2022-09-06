# ArchLinux Init

```sh
curl https://wiki.117503445.top/linux/script/ssh.sh | bash

timedatectl set-timezone Asia/Shanghai

cat>/etc/pacman.d/mirrorlist<<EOF
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
EOF

pacman -Syyu --noconfirm

pacman -S which zsh btop git docker docker-compose cronie nano vim micro --noconfirm

systemctl enable docker.service
systemctl enable cronie.service

# pacman -S net-tools dnsutils inetutils iproute2 --noconfirm

chsh -s $(which zsh)

# sudo gpasswd -a ${USER} docker

reboot
```

```sh

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone --depth=1 https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

tee ~/.zshrc <<-'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

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
EOF

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1m",
    "max-file": "1"
  }
}
EOF

reboot
```
