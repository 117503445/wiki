# sysctl

## quic UDP Buffer Size

部分 Go 程序使用了 quic-go 库，该库使用了 UDP 协议。在 Linux 系统上，UDP 协议的缓冲区大小是有限制的。如果缓冲区大小不够，可能会导致 quic-go 库的性能问题。

需要修改 `net.core.rmem_max=2500000` 和 `net.core.wmem_max=2500000`。

```bash
set -e

cat >> /etc/sysctl.d/99-quic-go.conf <<EOF
net.core.rmem_max=2500000
net.core.wmem_max=2500000
EOF

sysctl --system
```

`curl https://wiki.117503445.top/linux/script/sysctl-quic.sh | bash`

ref

- <https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes>
- <https://wiki.archlinux.org/title/sysctl>
