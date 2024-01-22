<!--
 * @Author: HaoTian Qi
 * @Date: 2022-03-02 10:48:18
 * @Description: 
 * @LastEditors: HaoTian Qi
 * @LastEditTime: 2022-03-02 10:48:19
-->

# Alpine 镜像源

```sh
sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
```

## ref

<https://www.jianshu.com/p/791c91b7c2a4>
