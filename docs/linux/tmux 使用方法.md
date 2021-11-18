# tmux 使用方法

## 省流

```bash
tmux new # 创建 新的 session
tmux new -s session-name # 创建 新的 session，指定 session 名称

Ctrl+b d # 离开当前 session
Ctrl+d # 关闭当前 session

tmux a # 回到第一个 session
tmux a -t session-name # 回到指定 session
```

## session 操作

```bash
tmux new # 创建 新的 session
    -s session-name # 指定 session 名称
    -d # 在后台运行

tmux detach # 离开当前 session

tmux kill-session -t <session-name> # 杀死某个 session

tmux switch -t <session-name> # 切换到某个 session

tmux ls # 查看当前 session 列表

Ctrl+d # 关闭当前 session

tmux a # 回到第一个 session
    -t session-name # 回到指定 session
```

## 操作

```bash
tmux split-window # 并列切分(切割线是横线)
    -h # 变为并排切分(切割线是竖线)

tmux select-layout tiled
```
