cat << EOF > /etc/sysctl.d/30-ipforward.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl --system

iptables -t nat -A POSTROUTING -o tailscale0 -j MASQUERADE
iptables -I DOCKER-USER 1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I DOCKER-USER 2 -i ens18 -o tailscale0 -j ACCEPT