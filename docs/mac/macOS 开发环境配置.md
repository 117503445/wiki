# macOS 开发环境配置

## 软硬环境

MacBook Pro(13-inch, M1, 2020) 8/256

macOS Big Sur 11.6

## VS Code

<https://code.visualstudio.com/Download>

## GitHub Desktop

<https://desktop.github.com/>

## Free Download Manager

<https://www.freedownloadmanager.org/zh/>

## 超级右键

可被系统快捷键替代

添加右键菜单

- 新建文件
- 用 VSCode 打开
- 用 Iterm 打开

## ClashX

<https://github.com/yichengchen/clashX>

提高部分网站的可访问性

## FileZilla

<https://filezilla-project.org/>

类似 WinSCP，管理服务器文件

## IINA

<https://iina.io/>

视频播放器

## iShot

<https://apps.apple.com/cn/app/ishot-%E4%BC%98%E7%A7%80%E7%9A%84%E6%88%AA%E5%9B%BE%E5%BD%95%E5%B1%8F%E5%B7%A5%E5%85%B7/id1485844094?mt=12>

截屏工具

## iTerm2

<https://iterm2.com/downloads.html>

更好的终端

## Rectangle

`brew install Rectangle`

窗口管理，提供类似 Windows 中 Win + Up 的快捷键

## Navicat

<https://www.macwk.com/soft/navicat-premium>

数据库管理工具

## Pock

<https://www.macwk.com/soft/pock>

自定义 Touchbar

## Scroll Reverser

<https://pilotmoon.com/scrollreverser/>

调整 触摸板、鼠标、滚轮 的滚动方向

在安装 Mos 的情况下可以不用

## Mos

<https://github.com/Caldis/Mos>

`brew install mos`

调整鼠标滚动方向，通过插帧平滑鼠标滚动效果

我用的是 罗技 Master 3s 鼠标，关闭阻尼的情况下手感非常恶心，开启阻尼并使用默认的平滑模式会有回弹现象，往下滚的最后会再往上滚。手感也相当不顺滑。

关闭罗技自带的平滑模式，使用 Mos 进行插帧，手感相当好，确实如同宣传标语 "让你的滚轮爽如触控板"

## Stats

<https://github.com/exelban/stats>

给功能栏添加 CPU占用显示 等功能

## Hidden Bar

<https://apps.apple.com/us/app/hidden-bar/id1452453066?mt=12>

将功能栏中不常用的图标隐藏起来

## alt-tab

`brew install alt-tab`

option + tab 时，隐藏不活跃的窗口。

## 脚本

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# add Homebrew to PATH

brew install --cask visual-studio-code
brew install orbstack
brew install --cask warp
brew install --cask neteasemusic
brew install fish
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish
brew install alt-tab
brew install Rectangle
brew install --cask snipaste
brew install --cask iina

brew install mos
brew install stats
brew install --cask hiddenbar
brew install MonitorControl
brew install go
go env -w GO111MODULE=on && go env -w GOPROXY=https://goproxy.cn,direct

brew install syncthing
brew install --cask docker

brew tap ivaquero/chinese
brew update
brew install --cask clash-verge-rev
brew edit clash-verge-rev # prevent hash mismatch
```

## VSCode Server 无法安装扩展

在 `devcontainer.json` 中写

```json
{
    "customizations": {
        "vscode": {
            "settings": {
                "extensions.verifySignature": false
            }
        }
    }
}
```

ref <https://github.com/microsoft/vscode-remote-release/issues/8541>
