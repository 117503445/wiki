# Homebrew 镜像源

ref <https://segmentfault.com/a/1190000037618113>

## 更换

```sh
# 替换 brew.git
cd "$(brew --repo)"
git remote set-url origin https://mirrors.aliyun.com/homebrew/brew.git

# 替换 homebrew-core.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://mirrors.aliyun.com/homebrew/homebrew-core.git

# 替换 homebrew-bottles 访问地址
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles' >> ~/.zshrc
source ~/.zshrc
```

## 还原

```sh
# 还原 brew.git
cd "$(brew --repo)"
git remote set-url origin https://github.com/Homebrew/brew.git

# 还原 homebrew-core.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://github.com/Homebrew/homebrew-core.git

# 还原的话就是删除HOMEBREW_BOTTLE_DOMAIN，上面的是zsh的命令，如果是bash的话请写在.bash_profile文件中。
```
