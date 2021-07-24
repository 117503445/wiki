# Linux 命令速查

## tar

mydir 文件夹 压缩为 mydir.tar.gz

`tar -zcvf mydir.tar.gz mydir`

解压 mydir.tar.gz

`tar -zxvf mydir.tar.gz`

## find

查找 ~/Desktop 路径下 tf-test.py 文件

`find ~/Desktop -iname tf-test.py`

## 查看外网 ipv6 地址

<https://serverfault.com/questions/1007184/how-to-check-ipv6-address-via-command-line>

```sh
curl -6 https://ifconfig.co
curl -6 https://ipv6.icanhazip.com
telnet -6 ipv6.telnetmyip.com
ssh -6 sshmyip.com
```
