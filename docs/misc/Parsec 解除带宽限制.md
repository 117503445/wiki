# Parsec 解除带宽限制

在配置文件中加入

```ini
encoder_min_bitrate = 40
```

即可强制最低码率为 40 mbps，否则选 50Mbps 它实际只用 15Mbps。

ref <https://mozz.ie/posts/ultimate-virtual-monitor-solution-indirect-display/>
