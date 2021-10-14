# python 开发环境

pip 设置 阿里源

```sh
pip config set global.index-url http://mirrors.aliyun.com/pypi/simple # v2rayN 下，https 会出问题
pip config set install.trusted-host mirrors.aliyun.com
```

升级 conda 及 base 环境 <https://www.cnblogs.com/ruhai/p/12684838.html>

```sh
conda upgrade conda 
conda update anaconda

conda install python
# or
# conda install python=3.9
```
