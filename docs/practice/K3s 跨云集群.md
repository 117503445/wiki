# K3s 跨云集群

更新于 2023.2.12

## 背景

计划搭建 K8s 集群用于提供比较稳定的服务。

我拥有多台云厂商的机器，稳定性非常高，但是内存都比较低，尤其是运行 Spring Boot 服务时会不够用。我也拥有多台内网设备，计算性能和内存都比云服务器高得多，但是不稳定。所以计划借助 K8s，使用云服务器作为控制平面和外部流量入口，后端服务运行在内网机器上。当某一台内网机器挂掉的时候，K8s 可以及时将流量切到另一台机器的服务上，从而保障服务整体的可用性。

因为云服务器的内存实在太小了，所以使用 K3s。K3s 作为轻量级的 K8s 发行版，对资源的占用非常低，适合边缘计算等场景。

因为只有一台云服务器，所以这台服务器将成为整个集群的单点。但是云服务器一般还是比较靠谱的，整体可用性也还能接受。

因为云服务器只有 1Mbps 的带宽，所以集群只能跑一些后端应用。更大带宽、负载均衡等方法尽管能解决这个问题，但是开销是难以承受的。不过可以把前端应用部署在 OSS 之类的地方。

## 机器信息

控制节点: 阿里云ECS 2c2g, 1Mbps
工作节点: 8c8g 及以上
操作系统: ArchLinux

## Tailscale 打通网络

因为集群中存在内网节点，云服务器无法直接和内网机器通讯。为了解决这个问题，需要用到 VPN 搭建虚拟的局域网。这里我选用 Tailscale, 它具有高性能的同时，易用性比 ZeroTier 更好。我还自己搭建了 Derper 服务器，用于协助握手和流量转发。具体见 [Tailscale 自建 & 旁路由](https://wiki.117503445.top/practice/Tailscale%20%E8%87%AA%E5%BB%BA%20%26%20%E6%97%81%E8%B7%AF%E7%94%B1/)。

通过 Tailscale，云服务器和每台内网机器都会分配到一个虚拟的 IP，机器之间通过这个 IP 即可直接通信。

## K3s 部署

在云服务器上执行下列安装命令。其中 `$MY_TAILSCALE_IP` 是云服务器的 Tailscale 虚拟 IP。`--disable traefik` 表示禁用默认安装的 Traefik 网关，因为我想安装 APISIX。`--node-taint node-role.kubernetes.io/control-plane:NoSchedule` 为云服务器打上了污点，避免容器被调度到云服务器上。这是因为云服务器的内存较小，尽量不要运行多余的容器。

```sh
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - --node-external-ip $MY_TAILSCALE_IP --flannel-backend=wireguard-native --flannel-external-ip  --node-taint node-role.kubernetes.io/control-plane:NoSchedule --disable traefik
```

然后执行 `cat /var/lib/rancher/k3s/server/node-token`，获取 K3s 的 token。

执行 `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`，可以考虑把这句命令放进 `.zshrc`。也可以拷贝。

```sh
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```

在内网机器上执行下列安装命令。其中 `$CLOUD_TAILSCALE_IP` 是云服务器的 Tailscale 虚拟 IP, `$MY_TAILSCALE_IP` 是内网机器的 Tailscale 虚拟 IP，`$NODE_TOKEN` 是 K3s 集群的 token。

```sh
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://$CLOUD_TAILSCALE_IP:6443 K3S_TOKEN=$NODE_TOKEN sh -s - --node-external-ip $MY_TAILSCALE_IP
```

安装 APISIX 及 dashboard

```sh
helm repo add apisix https://charts.apiseven.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install apisix apisix/apisix \
  --set gateway.type=LoadBalancer \
  --set gateway.tls.enabled=true \
  --set ingress-controller.enabled=true \
  --create-namespace \
  --namespace ingress-apisix \
  --set ingress-controller.config.apisix.serviceNamespace=ingress-apisix \
  --set ingress-controller.config.apisix.adminAPIVersion=v3 \
  --set ingress-controller.config.kubernetes.enableGatewayAPI=true \
  --kubeconfig /etc/rancher/k3s/k3s.yaml

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v0.5.0/standard-install.yaml --namespace ingress-apisix

helm install apisix-dashboard apisix/apisix-dashboard --create-namespace --namespace ingress-apisix
```

将自己的域名 DNS 解析到云服务器的 ip 上。比如自己拥有的域名是 `a.com`，云服务器域名是 `ali.a.com`。还需要进行泛域名解析，将 `*.ali.a.com` 解析到 `ali.a.com` 上。这样，可以用不同的 HTTP Host 区分不同的服务。比如 `apisix.ali.a.com` 用来表示 APISIX Dashboard, `whoami.ali.a.com` 表示访问 `whoami` 服务。

准备 `*.ali.a.com` 证书。可以使用 `ACME.sh` 脚本进行免费申请。写入 `~/.k8s/apisix/cert.yaml`。需要把 cert 和 key 经过 base64 编码后放入对应的位置。

```yaml
apiVersion: v1
data:
  cert: 123
  key: 456
kind: Secret
metadata:
  name: apisix-secret
  namespace: ingress-apisix
```

定义 `apisix.ali.a.com` 到 APISIX Dashboard 的路由。写入 `~/.k8s/apisix/dashboard.yaml`。其中 `apisix.ali.a.com` 替换成自己的域名。

```yaml
apiVersion: apisix.apache.org/v2
kind: ApisixUpstream
metadata:
  name: apisix-dashboard
  namespace: ingress-apisix
spec:
  loadbalancer:
    type: ewma
---
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: apisix-dashboard
  namespace: ingress-apisix
spec:
  http:
  - name: apisix-dashboard
    match:
      hosts:
      - apisix.ali.a.com
      paths:
      - /*
    backends:
    - serviceName: apisix-dashboard
      servicePort: 80
---
apiVersion: apisix.apache.org/v2
kind: ApisixTls
metadata:
  name: apisix-dashboard
  namespace: ingress-apisix
spec:
  hosts:
  - apisix.ali.a.com
  secret:
    name: apisix-secret
    namespace: ingress-apisix
```

然后执行 `kubectl apply -f ~/.k8s/apisix` 就可以通过 `https://apisix.ali.a.com` 访问 APISIX Dashboard 了。

最后部署一个 Whoami 服务。其他后端服务的部署也比较类似。

写入 `~/.k8s/whoami/whoami.yaml`。其中 `apisix.ali.a.com` 替换成自己的域名。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
spec:
  replicas: 3
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: traefik/whoami
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  type: NodePort
  ports:
  - name: http
    targetPort: 80
    port: 80
    nodePort: 30163
  selector:
    app: whoami
---
apiVersion: apisix.apache.org/v2
kind: ApisixUpstream
metadata:
  name: whoami
spec:
  loadbalancer:
    type: ewma
---
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: whoami
spec:
  http:
  - name: whoami
    match:
      hosts:
      - whoami.ali.a.com
      paths:
      - /*
    backends:
    - serviceName: whoami
      servicePort: 80
---
apiVersion: apisix.apache.org/v2
kind: ApisixTls
metadata:
  name: whoami
spec:
  hosts:
    - "whoami.ali.a.com"
  secret:
    name: apisix-secret
    namespace: ingress-apisix
```

然后执行 `kubectl apply -f ~/.k8s/whoami` 就可以通过 `https://whoami.ali.a.com` 访问 Whoami 服务了。

## 参考

<https://icloudnative.io/posts/deploy-k3s-cross-public-cloud/>
<https://docs.k3s.io/zh/>
