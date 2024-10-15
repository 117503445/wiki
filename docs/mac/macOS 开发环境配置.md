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

## key

```json
{
    "manipulators": [
        {
            "description": "Change delete_forward to left_command + delete_or_backspace",
            "from": {
                "key_code": "delete_forward"
            },
            "to": [
                {
                    "key_code": "delete_or_backspace",
                    "modifiers": [
                        "left_control"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```

```json
{
    "manipulators": [
        {
            "description": "Change command + h to option + control + f",
            "from": {
                "key_code": "h",
                "modifiers": {
                    "mandatory": [
                        "left_control"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "f",
                    "modifiers": [
                        "left_option",
                        "left_control"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```

```json
{
    "manipulators": [
        {
            "description": "Change alt + f4 to command + Option + w",
            "from": {
                "key_code": "f4",
                "modifiers": {
                    "mandatory": [
                        "left_alt"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "w",
                    "modifiers": [
                        "left_control",
                        "left_option"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```

```json
{
    "manipulators": [
        {
            "description": "Change F2 to Enter",
            "from": {
                "key_code": "f2"
            },
            "to": [
                {
                    "key_code": "return_or_enter"
                }
            ],
            "type": "basic"
        }
    ]
}
```

```json
{
    "manipulators": [
        {
            "description": "Change F5 to command + r",
            "from": {
                "key_code": "f5"
            },
            "to": [
                {
                    "key_code": "r",
                    "modifiers": [
                        "left_control"
                    ]
                }
            ],
            "type": "basic"
        }
    ]
}
```

```json
{
    "manipulators": [
        {
            "description": "Change left_shift to F17 when used alone",
            "from": {
                "key_code": "left_shift",
                "modifiers": {
                    "optional": [
                        "any"
                    ]
                }
            },
            "to": [
                {
                    "key_code": "left_shift"
                }
            ],
            "to_if_alone": [
                {
                    "key_code": "f17"
                }
            ],
            "type": "basic"
        }
    ]
}
```

## sing-box

```jsonc
{
    "log": {
        "disabled": false,
        "level": "trace",
        "timestamp": true,
        "output": "/opt/homebrew/var/log/singbox.log"
    },
    "experimental": {
        // https://sing-box.sagernet.org/configuration/experimental/clash-api/
        "clash_api": {
            "external_controller": "0.0.0.0:9090", // 定义 Clash API 的外部控制器地址。"0.0.0.0:9090" 表示在本机的9090端口上监听外部的连接请求。
            "default_mode": "rule", // 设置 Clash API 的默认模式。"rule" 模式意味着流量将根据用户定义的规则进行路由。
            "external_ui": "metacubexd", // 指定外部用户界面(UI)的名称。这里的 "metacubexd" 是一个自定义 UI 的名称。
            "external_ui_download_url": "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip", // 提供外部 UI 的下载 URL。这个 URL 是从 GitHub 上下载 "metacubexd" UI 的压缩包。
            "external_ui_download_detour": "alilang", // 定义下载外部 UI 时使用的转发策略。"select" 表示将通过'select'出口选择转发
            "secret": "iSBveBsKuvY3D9"
        }
    },
    // "dns": {
    //     "servers": [
    //         {
    //             "tag": "local",
    //             "address": "223.5.5.5",
    //             "detour": "direct"
    //         }
    //     ],
    //     "rules": [
    //         {
    //             "outbound": "any",
    //             "server": "local"
    //         }
    //     ],
    //     "strategy": "ipv4_only"
    // },
    "inbounds": [
        {
            "type": "mixed",
            "tag": "mixed-in",
            "listen": "0.0.0.0",
            "listen_port": 1080
        }
    ],
    "outbounds": [
        {
            "tag": "select",
            "type": "selector",
            "default": "alilang",
            "outbounds": [
                "alilang",
                "direct"
            ]
        },
        {
            "type": "socks",
            "tag": "alilang",
            "server": "127.0.0.1",
            "server_port": 13659,
            "version": "5"
        },
        {
            "type": "direct",
            "tag": "direct"
        }
    ],
    "route": {
        "rules": [
            // {
            //     "domain_suffix": [
            //         "google.com"
            //     ],
            //     "outbound": "select"
            // },
            {
                "rule_set": [
                    "geosite-gfw"
                ],
                "domain_suffix": [
                    "docs.docker.com"
                ],
                "outbound": "select"
            }
        ],
        "rule_set": [
            {
                "type": "remote",
                "tag": "geosite-gfw",
                "format": "binary",
                "url": "https://mirror.ghproxy.com/https://raw.githubusercontent.com/lyc8503/sing-box-rules/rule-set-geosite/geosite-gfw.srs",
                "download_detour": "direct"
            }
        ],
        "auto_detect_interface": true,
        "final": "direct"
    }
}
```

tabby 终端

## replace

```sh
#!/usr/bin/env bash
sed -i '.backup' 's/.mac:lang(zh-Hans){font-family:-apple-system,BlinkMacSystemFont,PingFang SC,Hiragino Sans GB,sans-serif}/.mac:lang(zh-Hans){font-family:"Microsoft YaHei Mono",-apple-system,BlinkMacSystemFont,PingFang SC,Hiragino Sans GB,sans-serif}/' "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/workbench.desktop.main.css"
```