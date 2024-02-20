# Hyper-V 端口映射

```powershell
# 管理员权限
winget install gsudo
sudo pwsh

# 查看端口转发条目
netsh interface portproxy show v4tov4

# 添加新的转发条目
netsh interface portproxy add v4tov4 listenport=对外提供访问服务的端口 listenaddress=主机的ip地址 connectaddress=虚拟机的ip地址 connectport=虚拟机里服务的端口

# 删除转发条目
netsh interface portproxy delete v4tov4 listenaddress=宿主机的ip地址 listenport=宿主机的端口
```

也可以使用 [PortProxyGUI](https://github.com/zmjack/PortProxyGUI)

ref <https://blog.howesky.com/archives/18.html>
