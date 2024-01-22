# 在 2023 年换个新 Shell

之前一直使用 zsh + oh-my-zsh，但在服务器上需要 3s 才能启动，感觉太慢了，所以打算换一个更快的、更现代的、更适合交互的 shell。

可以使用 `time zsh -i -c exit` 测量启动时间

ref <https://blog.skk.moe/post/make-oh-my-zsh-fly/>

（好像是在 NixOS 上使用 zplug 导致启动过慢的

## fish

开箱即用，命令补全、git

速度很快

`time fish -i -c exit` 0.169s

默认主题一般，路径用了正红色，太亮了

## Xonsh

开箱即用，命令补全、git，文件夹选择很方便

速度很快

`time xonsh -i -c exit` 1s

默认主题也比较漂亮

## nushell
    
开箱即用，命令补全、git

速度很快

`time nu -i -c exit` 0.1s

## 结论

使用 nushell。 nushell 由 Rust 编写。很年轻、现代，有自己的设计理念。主题可以使用 Starship。

2024.1.23 update fish 的兼容性更好，比如 VSCode 适配 fish，但不适配 nushell。所以还是用 fish 吧。
