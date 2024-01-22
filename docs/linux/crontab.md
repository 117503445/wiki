# crontab

执行

```sh
# use vim to edit
EDITOR=vim crontab -e

# use vs code to edit
EDITOR="code --wait" crontab -e
```

然后输入 cron 表达式即可，例如 `0 0 * * * echo "every day"`

[crontab 生成器](https://crontab.guru/)

其实更推荐使用 systemd 的 timer 实现定时任务
