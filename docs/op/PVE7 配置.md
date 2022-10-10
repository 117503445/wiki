# PVE7 配置

去除弹窗

```js
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```

更换更新订阅源可参考 <https://www.jianshu.com/p/98e87febfd5e>
