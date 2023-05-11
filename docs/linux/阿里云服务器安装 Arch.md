<!--
 * @Author: HaoTian Qi
 * @Date: 2021-12-13 01:40:28
 * @Description: 
 * @LastEditTime: 2023-05-12 01:58:11
 * @LastEditors: HaoTian Qi
-->

# 云服务器安装 ArchLinux

ref <https://github.com/felixonmars/vps2arch>

2023.01.18 阿里云 ECS 实践通过
2023.05.12 腾讯云 轻量应用服务器 实践通过

1. 云服务器安装 ubuntu 18.04

2. 修改 root 密码

3. 执行脚本

```sh
wget https://felixc.at/vps2arch && chmod +x vps2arch
./vps2arch -m https://mirrors.ustc.edu.cn/archlinux/
```

4. 通过 VNC 执行 `reboot -f`
