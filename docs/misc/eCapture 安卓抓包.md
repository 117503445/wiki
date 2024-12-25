# eCapture 安卓抓包

eCapture 基于 eBPF 技术，相比传统抓包工具，eCapture 直接在内核中进行抓包，无需关注 CA 证书安装、VPN 配置等问题。

## adb 连接手机

首先下载 adb <https://developer.android.com/tools/releases/platform-tools?hl=zh-cn>

保证电脑和安卓手机处于同一局域网

手机 - 开发者选项 - WLAN 调试 - 配对码

在电脑上连接

```shell
adb pair ipaddr:port
```

ref <https://developer.android.com/tools/adb?hl=zh-cn>

## 安装 eCapture

电脑下载 eCapture <https://github.com/gojue/ecapture/releases>

推送至手机

```shell
adb push ecapture /data/local/tmp/
adb shell chmod 777 /data/local/tmp/ecapture

adb shell
su # 切换到 root 用户，需要手机已 root
/data/local/tmp/ecapture tls
```

ref 

- <https://vanelst.site/2019/12/16/android-adb/>
- <https://ecapture.cc/zh/examples/android.html>
