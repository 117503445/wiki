# Python 开发环境

pip 设置 阿里源

```sh
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
```

Windows v2rayN 下，https 会出问题，可以使用 Http 镜像源

```sh
pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
pip config set install.trusted-host mirrors.aliyun.com
```

升级 conda 及 base 环境 <https://www.cnblogs.com/ruhai/p/12684838.html>

```sh
conda upgrade conda 
conda update anaconda

conda install python
# or
# conda install python=3.9

conda create -n myenv
conda create -n myenv python=3.9
```

requests 需要 socks 支持，在 ArchLinux 下可以

```sh
sudo pacman -S python-pysocks
```
