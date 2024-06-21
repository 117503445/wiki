# 双系统重启到 Windows

```sh
efibootmgr | grep "Windows Boot Manager" | tail -n 1 | head -c 8 | tail -c 4 |  xargs sudo efibootmgr -n
reboot
```
