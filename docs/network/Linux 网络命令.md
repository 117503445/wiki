# Linux 网络命令

## 静态信息

### ss

```sh
ss -s # 摘要统计信息

# Total: 1144
# TCP:   154 (estab 50, closed 45, orphaned 0, timewait 39)

# Transport Total     IP        IPv6
# RAW       3         1         2        
# UDP       37        29        8        
# TCP       109       97        12       
# INET      149       127       22       
# FRAG      0         0         0
```

```sh
ss -at '( dport = :22 or sport = :22 )' # 查看 22 端口的连接
```

```sh
ss -nlp | grep 8080 # 查看占用 8080 端口的进程 PID
```

```sh
ss -nlp | grep 8230 # 查看 PID = 8230 的进程监听的端口
```

[ss(8) — Linux manual page](https://man7.org/linux/man-pages/man8/ss.8.html)

[Using the ss command on Linux to view details on sockets](https://www.networkworld.com/article/3683910/using-the-ss-command-on-linux-to-view-details-on-sockets.html)

[12 ss Command Examples to Monitor Network Connections](https://www.tecmint.com/ss-command-examples-in-linux/)

### ip

```sh
ip neigh # 查看 ARP 表
```

```sh
sudo ip neighbour flush all # 清空 ARP 表
```

[ip-neighbour(8) — Linux manual page](https://man7.org/linux/man-pages/man8/ip-neighbour.8.html)

```sh
ip link # 查看网卡信息
```

```sh
ip link show eth0 # 查看 eth0 网卡信息
```

```sh
ip addr # 查看网卡的 IP 地址信息
```

```sh
ip addr show eth0 # 查看 eth0 网卡的 IP 地址信息
```

```sh
ip -s link # 查看网卡的统计信息
```

```sh
ip link set eth0 up # 启用 eth0 网卡
```

```sh
ip route # 查看路由表
```

```sh
ip route show table 52 # 查看路由表 52
```

## 主动探测

### ping

```sh
ping baidu.com
```

### traceroute

默认使用 UDP

```sh
traceroute baidu.com # baidu.com 网络连接统计信息
```

```sh
traceroute -I baidu.com # 使用 ICMP
```

### mtr

结合了 `traceroute` 和 `ping` 两种功能, 使用 ICMP

```sh
mtr baidu.com # baidu.com 网络连接统计信息
```

```sh
mtr --show-ips baidu.com # 显示 IP
```

```sh
mtr --report baidu.com # 生成报告
```

### dig

```sh
dig baidu.com # 查询 baidu.com 的 DNS 信息
```

```sh
dig baidu.com +short # 简短输出
```

```sh
dig baidu.com 223.5.5.5 # 指定查询服务器
```

```sh
dig baidu.com +trace # 追踪 DNS 解析过程
```

### resolvectl

```sh
resolvectl query baidu.com # 查询 baidu.com 的 DNS 信息
```

## HTTP 交互

### curl

```sh
curl https://wiki.117503445.top/linux/script/ssh.sh | bash # 从 URL 下载并执行脚本
```

```sh
# 不断重试下载
while true; do
    curl -C - -o ./PubLayNet_PDF.tar.gz https://dax-cdn.cdn.appdomain.cloud/dax-publaynet/1.0.0/PubLayNet_PDF.tar.gz &&
    break ||
    sleep 5
done
```

### wget

```sh
wget https://wiki.117503445.top/linux/script/ssh.sh -O - | bash # 从 URL 下载并执行脚本
```

## 抓包分析

通过以下工具把网络包抓到 pcap, 再丢进 wireshark 进行分析

### tcpdump

适合实时监测网络流量

```sh
sudo tcpdump -i eth0 -w 1.pcap # 抓取 eth0 网卡的网络包并保存到 1.pcap
```

```sh
tcpdump port 8080 # 抓取 8080 端口的网络包
tcpdump tcp # 抓取 tcp 网络包
tcpdump udp # 抓取 udp 网络包
tcpdump icmp # 抓取 icmp 网络包
tcpdump arp # 抓取 arp 网络包
tcpdump ip # 抓取 ip 网络包
```

```sh
tcpdump host 127.0.0.1 # 抓取 127.0.0.1 的网络包
tcpdump src 127.0.0.1 # 抓取源地址为 127.0.0.1 的网络包
tcpdump dst 127.0.0.1 # 抓取目标地址为 127.0.0.1 的网络包
```

### tcpflow

重建整个 TCP 流并提供更好的数据扫描效果

### ngrep

可以根据正则表达式进行过滤和捕获，是一种快速了解网络上发生情况的工具

```sh
sudo ngrep -t -d any 'Host: 127.0.0.1 and port 8080' # 抓取所有发送 127.0.0.1 端口号为 8080 的 HTTP 请求
```

## 过时工具

### nslookup

已 deprecated, 建议使用 dig

```sh
nslookup baidu.com # 查询 baidu.com 的 DNS 信息
```

```sh
nslookup baidu.com 223.5.5.5 # 指定查询服务器
```

### host

已 deprecated, 建议使用 dig

```sh
host baidu.com # 查询 baidu.com 的 DNS 信息
```

```sh
host baidu.com 223.5.5.5 # 指定查询服务器
```

```sh
host 123.125.66.120 # 查询 IP 的 DNS 信息, 反向查询
# 120.66.125.123.in-addr.arpa domain name pointer baiduspider-123-125-66-120.crawl.baidu.com.
```

### netstat

已 deprecated, 建议使用 ss

```sh
netstat -i # 按接口查看发送/接收统计信息
```

```sh
netstat -nlp | grep :8080 # 查看占用 8080 端口的进程 PID

# -n：以数字形式显示网络地址和端口号，而不是主机名和服务名称。
# -l：只显示正在监听（listening）的网络连接。
# -p：显示进程 ID 或名称，与每个网络连接相关联。
```

```sh
netstat -nlp | grep 8230 # 查看 PID = 8230 的进程监听的端口
```

[netstat(8) - Linux man page](https://linux.die.net/man/8/netstat)
[Linux networking: 13 uses for netstat](https://www.redhat.com/sysadmin/netstat)

### ifconfig

已过时, 建议使用 ip

### route

已过时, 建议使用 ip

### arp

已过时, 建议使用 ip
