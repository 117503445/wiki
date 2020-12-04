# 持续集成工作流

## 概要

### 目标

- 使用 Git 提交代码后,自动编译,并自动上线.

- 支持 HTTPS

- 单服务器可以承载多个后端服务

- 访问每个后端服务时,只有域名不同

- 可以很方便的区分测试环境和生产环境

- 前后端完全分离,前端部署在高速的OSS上享受CDN加速,且可由前端人员自己完成前端文件的更新.

### 使用的技术/产品

- Git

- Github

- Docker

- Docker Hub

- Nginx

- OSS

- 跨域

### 示例

域名为 Domain.com 的服务器上,运行 后端服务A 8000,后端服务B 8001.

显然,此时,通过 <http://backend.Domain.com:8000> 和 <http://backend.Domain.com:8001> 即可通过不安全的 HTTP 访问后端服务.

通过 Nginx ,我们可以做到 <https://a.backend.Domain.com> 和 <https://b.backend.Domain.com> 分别通过安全的 HTTPS 访问后端服务.对于用户访问网站的时候,显然要访问前端文件.给用户的网站地址是 a.Domain.com,然后前端通过 ajax 等方法与 <https://a.backend.Domain.com> 通信.

## 持续集成

### 目标

这一部分,我们要做到的是以持续集成的方式,在 <http://backend.Domain.com:8000> 上运行起 服务.

### 概要

程序员将代码推送到 Github 上 -> Docker Hub 检测到 Github 仓库发生了改变,使用它的服务器 Clone 代码,并且执行 Docker build 构建镜像,完成构建后发送到 Docker Hub 上 -> 服务器定时检测 Docker Hub 是否有更加新的镜像.如果有,就运行新的镜像.

### Git / Github

为了便于后续的 Docker 化,项目名称最好不要使用大写字母,多使用小写字母+下划线

采用 commit 规范
<https://blog.csdn.net/y491887095/article/details/80594043>

#### Commit message格式

\<type>: \<subject>

注意冒号后面有空格。

##### type

> 用于说明 commit 的类别，只允许使用下面7个标识。

- feat: 新功能(feature)
- fix: 修补bug
- docs: 文档(documentation)
- style: 格式(不影响代码运行的变动)
- refactor: 重构(即不是新增功能，也不是修改bug的代码变动)
- test: 增加测试
- chore: 构建过程或辅助工具的变动

如果type为feat和fix，则该 commit 将肯定出现在 Change log 之中。

##### subject

> subject 是 commit 目的的简短描述，不超过50个字符，且结尾不加句号 '.'

### Docker 化项目

编写 dockerfile 文件

比较棘手的一点是私密的环境变量不能随意存放.任何时候都要确保 Git 中没有私密配置文件.另一方面,镜像也是公开的,所以私密配置不能在镜像构建 docker build 的时候加入,只能在最后镜像运行 docker run 的时候加入.

对于编译型语言,要使用docker的分层构建功能,确保最后生成的镜像中,只有最简单的二进制文件以及运行环境,没有代码和各种JDK.

对于 Java 的 Spring Boot ,Go 的 Gin, 我都已经编写了docker化的示例代码,详情见

<https://github.com/117503445/spring_boot_docker>

<https://github.com/117503445/go_docker>

对于 Python 的 Flask ,没有专门的示例代码,可以参考

<https://github.com/117503445/XduCheckInLog>

### Docker Hub 自动构建

每次代码发生更新,就需要有机器去拉取代码,执行 docker build.幸运的是,docker hub提供了这些功能

可以参考 <https://blog.csdn.net/xichenguan/article/details/79083630> 进行操作

### 本地自动拉取

docker hub 完成了镜像的构建以后,还需要服务器定时去主动的拉取镜像,更新正在运行的后端服务,完成项目上线.

watchtower 就可以很给力的完成这个任务.watchtower本身也可以使用docker镜像的方式运行.

运行

```sh
docker run -d  --restart=always \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower
```

就可以启用 watchtower 镜像,此后每 5 min,服务器都会去查看docker hub 是否有版本更加新的镜像,如果有,就删除当前镜像,拉取新镜像,并使用相同的运行参数完成新的镜像.上述的代码会检查所有镜像的更新,如果只想对特定的镜像进行检查,可以去查 watchtower 的文档,修改参数.

## 美观的域名

### 示例

域名为 Domain.com 的服务器上,运行 后端服务A 8000,后端服务B 8001.
显然,此时,通过 <http://backend.Domain.com:8000> 和 <http://backend.Domain.com:8001> 即可通过不安全的 HTTP 访问后端服务.
通过 Nginx ,我们可以做到 <https://a.backend.Domain.com> 和 <https://b.backend.Domain.com> 分别通过安全的 HTTPS 访问后端服务.对于用户访问网站的时候,显然要访问前端文件.给用户的网站地址是 a.Domain.com,然后前端通过 ajax 等方法与 <https://a.backend.Domain.com> 通信.

### 证书准备

先将 a.backend.Domain.com 和 b.backend.Domain.com 都采用 CNAME 的方式解析到 <https://a.Domain.com> 上.

比较方便的是使用阿里云的免费证书,如果域名也是阿里云的就更加方便了.

切换到阿里云的 SSL证书 功能页面,购买证书,选中免费的,然后 申请 a.backend.Domain.com 和 b.backend.Domain.com 并启动验证,就可以获得证书了,下载 nginx 的,进行重命名,pem结尾的是公钥,key结尾的是密钥

这时候我们分析一下,用户访问 <https://a.backend.Domain.com> 和 <https://b.backend.Domain.com> 的时候,实际都会访问 <https://a.Domain.com> 的443端口.但是从 HTTP 的角度来看,这2个请求中的 host 是不一样的,所以可以根据 host 字段转发到不同的后端服务上去.同时,在转发过程中,也可以加上 TLS 层.

具体来说,就需要使用 Nginx 了.

创建相关文件结构如下

```conf
nginx - crt - a.backend.Domain.com.key
            - a.backend.Domain.com.pem
            - b.backend.Domain.com.key
            - b.backend.Domain.com.pem
      - DockerFile

      - nginx.conf
```

DockerFile 内容

```sh
FROM nginx1
ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./crt ./root/crt
```

nginx.conf 内容

```conf
user nginx;
worker_processes 1;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;


events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    keepalive_timeout 65;

    server{
        server_name a.backend.Domain.com;
        listen 443 ssl;
        ssl_certificate /root/crt/a.backend.Domain.com.pem;
        ssl_certificate_key /root/crt/a.backend.Domain.com.key;
        location / {
            proxy_pass http://127.0.0.1:8000;
        }
    }

    server{
        server_name b.backend.Domain.com;
        listen 443 ssl;
        ssl_certificate /root/crt/b.backend.Domain.com.pem;
        ssl_certificate_key /root/crt/b.backend.Domain.com.key;
        location / {
            proxy_pass http://127.0.0.1:8001;
        }
    }
}
```

主要看 Server 部分

ssl_certificate 定义了公钥路径
ssl_certificate_key 定义了密钥路径

访问 <https://a.backend.Domain.com> 时,Nginx 就会发现 HTTP 包里的 Host 和第一个 server 块中 的 server_name 相同,所以会转发到本机的 <http://127.0.0.1:8000> 上,并提供了 SSL 服务.
同理,访问 <https://b.backend.Domain.com> 时,会转发到 本机的 <http://127.0.0.1:8001> 上,并提供了 SSL 服务.

最后使用 docker 运行 Nginx

```sh
docker rm mynginx -f
docker build -t my_nginx ./nginx
docker run --name mynginx -d -p 80:80 -p 443:443 my_nginx
```

## 前端 OSS

一般来说,会把前端文件也放在服务端里.但是这样有2个不好的地方.第一是服务器的网络带宽不够,阿里云服务器只有5m,就算只给一个用户传递网页文件也会卡,更别说更大的并发量了.第二就是前后端分离不彻底,每次前端更新,都必须依靠后端才能部署.

所以,可以借助 ali oss ,把前端文件放在OSS上,就能解决上述的2个问题了

把前端文件放进 oss 并绑定上 a.Domain.com

用户访问  a.Domain.com  时就可以访问到 静态前端文件了

然后前端文件再访问 a.backend.Domain.com 与 服务器交互

可以参考 <https://help.aliyun.com/document_detail/67323.html?spm=a2c4g.11186623.6.723.7104300eVXRz4Z>

记录一个坑

记得把 基础设置 -> 默认首页 和 默认 404 页 都改成 index.html.当然,具体操作要看前端文件是怎么样的.

然后创建一个子账号,授予权限,然后就可以把子账号交给前端,前端下载 oss-browser,就可以由前端自行控制文件上传了.

a.Domain.com 访问到 a.backend.Domain.com 的内容,会触发跨域问题.记得前后端一起协同处理.
