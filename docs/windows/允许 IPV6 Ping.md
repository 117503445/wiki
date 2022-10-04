# 允许 IPV6 Ping

ref <https://blog.k-res.net/archives/2484.html>

使用 IPV6 Ping Windows 没有 Ping 通，可能是因为 ICMPv6 包被 Windows 的防火墙拦截了。在管理员权限下的 PowerShell 输入 `netsh firewall set icmpsetting type=all mode=enable` 即可关闭拦截规则。
