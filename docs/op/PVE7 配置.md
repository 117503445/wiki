# PVE7 配置

## 去除弹窗

```sh
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```

## 更新订阅源

<https://www.jianshu.com/p/98e87febfd5e>

```sh
echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list
mv /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak

# Proxmox 软件源
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Debian 系统源
sed -i.bak "s#ftp.debian.org/debian#mirrors.aliyun.com/debian#g" /etc/apt/sources.list
sed -i "s#security.debian.org#mirrors.aliyun.com/debian-security#g" /etc/apt/sources.list

# LXC 仓库源
sed -i.bak "s#http://download.proxmox.com/images#https://mirrors.ustc.edu.cn/proxmox/images#g" /usr/share/perl5/PVE/APLInfo.pm  
wget -O /var/lib/pve-manager/apl-info/mirrors.ustc.edu.cn https://mirrors.ustc.edu.cn/proxmox/images/aplinfo-pve-7.dat
systemctl restart pvedaemon

# CEPH 源
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-pacific bullseye main" > /etc/apt/sources.list.d/ceph.list
sed -i.bak "s#http://download.proxmox.com/debian#https://mirrors.ustc.edu.cn/proxmox/debian#g" /usr/share/perl5/PVE/CLI/pveceph.pm

apt update && apt dist-upgrade
```

## noVNC Paste

ref <https://gist.github.com/amunchet/4cfaf0274f3d238946f9f8f94fa9ee02>

油猴脚本安装 <https://gist.github.com/amunchet/4cfaf0274f3d238946f9f8f94fa9ee02/raw/0b84970f89e1f282f09b86d46227eda71178c040/noVNCCopyPasteProxmox.user.js>

右键即可粘贴

```js
// ==UserScript==
// @name         noVNC Paste for Proxmox
// @namespace    http://tampermonkey.net/
// @version      0.2a
// @description  Pastes text into a noVNC window (for use with Proxmox specifically)
// @author       Chester Enright
// @match        https://*
// @include      /^.*novnc.*/
// @require http://code.jquery.com/jquery-3.3.1.min.js
// @grant        none
// ==/UserScript==
const delay = 1
;(function () {
    'use strict'
    window.sendString = function(text) {

        var el = document.getElementById("canvas-id")
        text.split("").forEach(x=>{
            setTimeout(()=>{
                 var needs_shift = x.match(/[A-Z!@#$%^&*()_+{}:\"<>?~|]/)
                 let evt
                 if (needs_shift) {

                     evt = new KeyboardEvent("keydown", {keyCode: 16})
                     el.dispatchEvent(evt)
                     evt = new KeyboardEvent("keydown", {key: x, shiftKey: true})
                     el.dispatchEvent(evt)
                     evt = new KeyboardEvent("keyup", {keyCode: 16})
                     el.dispatchEvent(evt)

                 }else{
                     evt = new KeyboardEvent("keydown", {key: x})
                }
                el.dispatchEvent(evt)
            }, delay)
        })

    }


    $(document).ready(function() {
        setTimeout(()=>{
            console.log("Starting up noVNC Copy/Paste (for Proxmox)")

            $("canvas").attr("id", "canvas-id")

            $("canvas").on("mousedown", (e)=>{
                if(e.button == 2){ // Right Click
                    navigator.clipboard.readText().then(text =>{
                        window.sendString(text)
                    })
                }
            })
        }, 1000);
    })


})()
```
