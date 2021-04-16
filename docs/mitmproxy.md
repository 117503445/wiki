# MITMProxy

## 介绍

一款代理软件，我们让自己的应用走这个代理，然后就可以拦截到网络请求，并进行分析。

这是 Python 写的，支持用户使用 Python 脚本 作为 addon 的形式进行执行，然后在 脚本 中就可以写拦截到请求以后的逻辑了。

我这次的需求就是有很多 Python 脚本，要知道它们会发出怎么样的网络请求，然后用 curl 的形式导出。

## 安装

pip install mitmproxy

## 运行代理

mitmproxy -s addons.py

其中 addons.py 内容为

```python
from mitmproxy import http
from htutil import file
import json
from mitmproxy.addons import export


def request(flow: http.HTTPFlow):
    file.append_all_text('tmp.txt', export.curl_command(flow)+'\n')

```

即把 request 类型 的 flow 转为 curl 形式，追加到 tmp.txt 中

http.HTTPFlow 具体的类定义可以查看 <https://github.com/mitmproxy/mitmproxy/blob/main/mitmproxy/http.py>

也可以看看官方示例 <https://docs.mitmproxy.org/stable/addons-overview/>

## 运行脚本

比如我要抓取 test.py 的请求

在 Linux 下

`http_proxy=http://localhost:8080/ python test.py` 即可
