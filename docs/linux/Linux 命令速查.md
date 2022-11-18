# Linux 命令速查

## tar

mydir 文件夹 归档为 mydir.tar

`tar -cvf mydir.tar mydir`

mydir 文件夹 压缩为 mydir.tar.gz

`tar -zcvf mydir.tar.gz mydir`

解压 mydir.tar

`tar -xvf mydir.tar`

解压 mydir.tar.gz

`tar -zxvf mydir.tar.gz`

参数

```sh
-z 压缩
-c 建立一个压缩文件
-v 压缩时显示文件列表
-f 打包后的文件名，必须在最后
```

可以在 .zshrc 中 添加以下代码，作为快捷方式

```sh
# create .tar
ta() { tar -cvf $1.tar $1; }
# create .tar.gz
targz() { tar -zcvf $1.tar.gz $1; }
# extract .tar
untar() { tar -xvf $1; }
# extract .tar.gz
untargz() { tar -zxvf $1; }
```

## find

查找 ~/Desktop 路径下 tf-test.py 文件

`find ~/Desktop -iname tf-test.py`

## 大文件定位

`du -h / --max-depth=1 | sort -hr | head -n 10`

## 高内存占用进程定位

`ps aux|head -1;ps aux|grep -v PID|sort -rn -k +4|head`

## 查看文件夹大小

`du -h --max-depth=1 .`

-h 用单位 表示大小

. 要查看大小的文件夹

## 端口

`lsof -i:8080`

## 主机名

`code /etc/hostname`

重启后生效

## 显存

`glxinfo | egrep -i 'device|memory|video'`
