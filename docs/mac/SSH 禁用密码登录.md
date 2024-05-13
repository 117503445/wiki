# SSH 禁用密码登录

ref <https://apple.stackexchange.com/a/420554>

修改 `/etc/ssh/sshd_config` 文件，添加如下内容

```sh
PasswordAuthentication no
ChallengeResponseAuthentication no
```

重启 SSH 服务

```sh
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
```
