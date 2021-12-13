<!--
 * @Author: HaoTian Qi
 * @Date: 2021-12-13 01:40:28
 * @Description: 
 * @LastEditTime: 2021-12-13 11:00:04
 * @LastEditors: HaoTian Qi
-->

# 阿里云服务器安装 Arch

ref <https://web-worker.cn/Tutorial/vps2arch.html>

2021.12.13 轻量应用服务器 实践通过

1. 阿里云服务器安装 ubuntu 16.04

2. 修改 root 密码

3. 执行脚本

    ```sh
    wget https://wiki.117503445.top/linux/script/vps2arch.sh && chmod +x vps2arch.sh
    sudo ./vps2arch.sh -m https://mirrors.aliyun.com/archlinux/
    ```

4. ssh 登录

    `ssh root@ip`

5. 编辑 `/etc/pacman.d/mirrorlist`

    启用 China 镜像

6. 