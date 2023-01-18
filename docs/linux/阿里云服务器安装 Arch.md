<!--
 * @Author: HaoTian Qi
 * @Date: 2021-12-13 01:40:28
 * @Description: 
 * @LastEditTime: 2023-01-18 23:25:58
 * @LastEditors: HaoTian Qi
-->

# 阿里云服务器安装 Arch

ref <https://github.com/felixonmars/vps2arch>

2023.01.18 ECS 实践通过

1. 阿里云服务器安装 ubuntu 16.04

2. 修改 root 密码

3. 执行脚本

    ```sh
    wget https://felixc.at/vps2arch && chmod +x vps2arch
    ./vps2arch -m https://mirrors.ustc.edu.cn/archlinux/
    ```

4. 通过 VNC 执行 `reboot -f`
