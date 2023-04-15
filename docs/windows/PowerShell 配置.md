# PowerShell 配置

下载最新的 PowerShell <https://github.com/PowerShell/PowerShell/releases/latest>

安装 Windows Terminal

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

运行

```powershell
oh-my-posh init powershell
```

得到激活命令

```powershell
(@(& 'C:/Program Files (x86)/oh-my-posh/bin/oh-my-posh.exe' init powershell --config='' --print) -join "`n") | Invoke-Expression
```

编辑启动脚本

```powershell
code $Profile
```

再将上面的激活命令写进启动脚本
