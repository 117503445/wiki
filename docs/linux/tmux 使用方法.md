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

## 例子

运行 [dragonboat](https://github.com/lni/dragonboat) 项目的 helloworld 示例，需要同时运行三个程序。

```sh
rm example-helloworld
go build -v -o example-helloworld github.com/lni/dragonboat-example/v3/helloworld

name="dragonboat-helloworld"

tmux set -g mouse on # 启用鼠标、触摸板支持

tmux kill-session -t $name
tmux new-session -s $name -d

tmux split-window -t $name -h # 创建第二个 panel
tmux split-window -t $name -h # 创建第三个 panel

tmux select-pane -t 0 # 选中第一个 panel
tmux select-layout even-horizontal # 纵向等宽排列

tmux send-keys -t 0 "./example-helloworld -nodeid 1" C-m
tmux send-keys -t 1 "./example-helloworld -nodeid 2" C-m
tmux send-keys -t 2 "./example-helloworld -nodeid 3" C-m

tmux attach-session -t $name
```
