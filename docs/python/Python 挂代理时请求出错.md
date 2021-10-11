# Python 挂代理时请求出错

## 问题描述

挂着代理的时候，出现错误

```text
    raise ValueError("check_hostname requires server_hostname")
ValueError: check_hostname requires server_hostname
```

## 原因

urllib3 新版本的锅 (2021-9-16 ，urllib3 版本 1.26.4，是有问题的)

## 解决方案

降级到旧版本的 urllib3

`pip install urllib3==1.25.11`
