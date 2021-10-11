# https://zh.codepre.com/how-to-8568.html

apt install zsh -y
chsh -s $(which zsh)

exit

echo $SHELL
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

cd ~/.oh-my-zsh/custom/plugins/

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git

# git clone https://g.ioiox.com/https://github.com/zsh-users/zsh-syntax-highlighting.git
# git clone https://g.ioiox.com/https://github.com/zsh-users/zsh-autosuggestions.git

tee ~/.zshrc <<-'EOF'
export ZSH="/root/.oh-my-zsh"

ZSH_THEME="agnoster"

ENABLE_CORRECTION="true"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
EOF

source ~/.zshrc