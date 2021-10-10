# WSL2 配置

## 方法

在 `%UserProfile%\.wslconfig` 写入

```ini
[wsl2]
processors=8
memory=8GB
swap=8GB
```

## 取值

```plaintext
processors = cpu core number
memory = min(0.25 * total_memory, 8GB)
swap = 0.25 * total_memory
```

## Ref

<https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig>
<https://dowww.spencerwoo.com/4-advanced/4-3-wslconfig.html>
<https://zhuanlan.zhihu.com/p/345645621>
<https://docs.microsoft.com/zh-cn/windows/wsl/setup/environment>
