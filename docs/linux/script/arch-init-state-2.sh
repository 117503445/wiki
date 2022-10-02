set -e

sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

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
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "1m",
    "max-file": "1"
  }
}
EOF

reboot