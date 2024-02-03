cat >> /etc/sysctl.d/99-quic-go.conf <<EOF
net.core.rmem_max=2500000
net.core.wmem_max=2500000
EOF

sysctl --system