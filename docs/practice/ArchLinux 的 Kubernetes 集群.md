# ArchLinux 的 Kubernetes 集群

更新于 2022.10.17

脚本尽量自动化，需要修改的地方也标明了。

## 机器信息

计划在局域网内使用 kubeadm 搭建单主集群

使用 PVE 在服务器上创建了 4 个虚拟机

|  IP   | 操作系统  | 配置 | hostname | 用途
|  ----  | ----  | ---- | ---- | ---- |
| 192.168.2.160  | ArchLinux | 8C8G, 40G | arch-k8s-cluster2-master1 | master 节点
| 192.168.2.161  | ArchLinux | 8C8G, 40G | arch-k8s-cluster2-worker1 | worker1 节点
| 192.168.2.162  | ArchLinux | 8C8G, 40G | arch-k8s-cluster2-worker2 | worker2 节点
| 192.168.2.163  | ArchLinux | 8C8G, 40G | arch-k8s-cluster2-worker3 | worker3 节点

并使用了 [ArchLinux 初始化脚本](https://wiki.117503445.top/linux/script/arch-init.sh) 进行初始化。

<https://wangyue.dev/lts/> 描述了过高的内核版本会与某些组件产生兼容性问题，建议更换为 LTS 内核。

## K8s 部署

```sh
# 更换为 LTS 内核
pacman -S linux-lts --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg
reboot

uname -a # 检查内核是否更换成功
```

安装 kubeadm。K8s 的部署工具还有 Rancher 和 sealos 等，本文中选用官方的 kubeadm。

```sh
pacman -Sy kubeadm --noconfirm
```

安装和 K8s 有关的 cli。kubectl 是默认的 K8s cli，helm 类似于 K8s 的包管理器，用于简化复杂应用的部署。

```sh
pacman -Sy kubectl helm --noconfirm # only on master
```

K8s 是调度容器的系统，需要在每个节点上安装容器运行时。Docker 名气很大，但是在 K8s 中我选择 CRI-O 作为容器运行时。

```sh
pacman -Sy cri-o --noconfirm
```

配置 CRI-O

```sh
cat>/etc/containers/registries.conf<<EOF
unqualified-search-registries = ["docker.io"] # docker.io 作为默认的容器仓库
EOF


# 也可以使用容器镜像源，但是可能有坑
cat>/etc/containers/registries.conf<<EOF
unqualified-search-registries = ["docker.io"] # docker.io 作为默认的容器仓库

[[registry]]
prefix = "k8s.gcr.io/coredns/coredns" # 设置 coredns 的镜像源
location = "registry.aliyuncs.com/google_containers/coredns"
 
[[registry]]
prefix = "*.gcr.io" # 设置 gcr.io 的镜像源
location = "registry.aliyuncs.com/google_containers"
EOF

# 添加网络插件搜索路径
# https://wiki.archlinux.org/title/CRI-O#Plugin_Installation
cat>/etc/crio/crio.conf.d/00-plugin-dir.conf<<EOF
[crio.network]
plugin_dirs = [
  "/opt/cni/bin/",
]
EOF

systemctl enable --now crio.service
```

K8s 强烈建议关闭交换

```sh
cat>/lib/systemd/system/turnswapoff.service<<EOF
[Unit]
Description=Turn swap off 

[Service]
ExecStart=/sbin/swapoff -a

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now turnswapoff.service
```

安装 kubelet, kubelet 是 K8s 运行在每个节点上的 "node agent"

```sh
echo "y" "\n" "Y" | pacman -Sy kubelet
systemctl enable --now kubelet.service
```

拉取 K8s 组件所需镜像

```sh
kubeadm config images pull
```

初始化集群。其中 `pod-network-cidr` 指定了 pod 会分配到的 ip 范围，最后 pod 的 ip 会是 `10.217.0.1`, `10.217.0.2` 之类的。

`pod-network-cidr` 的取值是受到 CNI 网络插件的限制的。我选用了 Cilium 插件，Cilium 要求的 `pod-network-cidr` 就是 `10.217.0.0/16` 。集群创建完成以后再修改 `pod-network-cidr` 就比较麻烦，所以建议在集群创建前就做好 CNI 网络插件的选型。

[CNI](https://github.com/containernetworking/cni) 用于协调容器间的网络连接。因为各个部署环境下的网络条件差别巨大，所以 K8s 就把这一部分网络需求抽象成了接口，由不同的网络插件进行实现，以适应不同的网络环境。常见的 CNI 插件有 Flannel, Calico, Cilium 等。我一开始觉得 Flannel 的网络机制最简单，就尝试使用 Flannel，结果一整个国庆假期都花在处理各种网络问题上了，最后也没有成功，后来我换成 Cilium 一下子就搞定了。一方面，Cilium 的文档更加完善，而且还有仪表盘、可观测性等功能，eBPF 等黑科技。另一方面，kubeadm 的开发者也不推荐使用 Flannel，见 <https://github.com/kubernetes/kubeadm/issues/1817#issuecomment-538311661>。

```sh
kubeadm init --pod-network-cidr=10.217.0.0/16 # only on master
```

输出如下所示

```
[init] Using Kubernetes version: v1.25.2
[preflight] Running pre-flight checks
        [WARNING SystemVerification]: missing optional cgroups: blkio
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [arch-k8s-cluster2-master1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.2.160]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [arch-k8s-cluster2-master1 localhost] and IPs [192.168.2.160 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [arch-k8s-cluster2-master1 localhost] and IPs [192.168.2.160 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 23.505077 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node arch-k8s-cluster2-master1 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node arch-k8s-cluster2-master1 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 969kid.0v8m4105arlt0ggj
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.2.160:6443 --token 969kid.0v8m4105arlt0ggj \
        --discovery-token-ca-cert-hash sha256:c0cf33f2454e0e299949d8088ae48e70fccc397f679b8337f7383928c98a8409
```

在输出的末尾打印了 join 命令，在 worker 节点上执行以下命令加入集群。至此，worker 节点就不需要再执行命令了，剩下所有操作都在 master 节点上进行。

```sh
kubeadm join 192.168.2.160:6443 --token 969kid.0v8m4105arlt0ggj \
        --discovery-token-ca-cert-hash sha256:c0cf33f2454e0e299949d8088ae48e70fccc397f679b8337f7383928c98a8409
```

指定 `KUBECONFIG` 环境变量，并写入到 shell 的启动脚本中。

```sh
export KUBECONFIG=/etc/kubernetes/admin.conf
echo '\nexport KUBECONFIG=/etc/kubernetes/admin.conf'>>~/.zshrc
```

然后集群就跑起来了，可以通过 `kubectl` 进行管理。

```sh
> kubectl get nodes
NAME                        STATUS   ROLES           AGE   VERSION
arch-k8s-cluster2-master1   Ready    control-plane   8d    v1.25.2
arch-k8s-cluster2-worker1   Ready    <none>          8d    v1.25.2
arch-k8s-cluster2-worker2   Ready    <none>          8d    v1.25.2
arch-k8s-cluster2-worker3   Ready    <none>          8d    v1.25.2
```

安装 yay

```sh
# 添加 ArchLinuxCN 镜像源
cat>>/etc/pacman.conf<<EOF
[archlinuxcn]
Server = https://repo.archlinuxcn.org/\$arch
EOF

pacman -Syu archlinuxcn-keyring --noconfirm
pacman -S base-devel --noconfirm
pacman -S yay --noconfirm
```

安装 cilium cli

```sh
yay -S cilium-cli-bin hubble-bin
```

在 K8s 集群中部署 cilium

```sh
cilium install
cilium hubble enable --ui # 启用 hubble
cilium connectivity test # 执行网络连通性测试
```

查看 cilium 状态

```sh
> cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:         OK
 \__/¯¯\__/    Operator:       OK
 /¯¯\__/¯¯\    Hubble:         OK
 \__/¯¯\__/    ClusterMesh:    disabled
    \__/

DaemonSet         cilium             Desired: 4, Ready: 4/4, Available: 4/4
Deployment        hubble-ui          Desired: 1, Ready: 1/1, Available: 1/1
Deployment        hubble-relay       Desired: 1, Ready: 1/1, Available: 1/1
Deployment        cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
Containers:       cilium             Running: 4
                  hubble-ui          Running: 1
                  hubble-relay       Running: 1
                  cilium-operator    Running: 1
Cluster Pods:     30/32 managed by Cilium
Image versions    cilium-operator    quay.io/cilium/operator-generic:v1.12.2@sha256:00508f78dae5412161fa40ee30069c2802aef20f7bdd20e91423103ba8c0df6e: 1
                  cilium             quay.io/cilium/cilium:v1.12.2@sha256:986f8b04cfdb35cf714701e58e35da0ee63da2b8a048ab596ccb49de58d5ba36: 4
                  hubble-ui          quay.io/cilium/hubble-ui-backend:v0.9.2@sha256:a3ac4d5b87889c9f7cc6323e86d3126b0d382933bd64f44382a92778b0cde5d7: 1
                  hubble-ui          quay.io/cilium/hubble-ui:v0.9.2@sha256:d3596efc94a41c6b772b9afe6fe47c17417658956e04c3e2a28d293f2670663e: 1
                  hubble-relay       quay.io/cilium/hubble-relay:v1.12.2@sha256:6f3496c28f23542f2645d614c0a9e79e3b0ae2732080da794db41c33e4379e5c: 1
```

开始准备储存。目标是把 worker1 节点的 `/root/nfs` 目录制备为 nfs 的动态卷类型。这非常不适合生产环境，只要 worker1 挂了，所有需要储存的 pod 就挂了，但是对于测试环境还是挺方便的。

```sh
mkdir -p /root/nfs # in worker1

# in master
# 指定 arch-k8s-cluster2-worker1 节点上的 /root/nfs 目录为 PersistentVolume
cat>~/.k8s/sc/pv.yaml<<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: arch-k8s-cluster2-worker1-nfs
spec:
  capacity:
    storage: 20Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  local:
    path: /root/nfs
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - arch-k8s-cluster2-worker1
EOF
kubectl apply -f ~/.k8s/sc/pv.yaml

# nfs driver
cat>~/.k8s/sc/nfs-helm-values.yaml<<EOF
persistence:
  enabled: true
  storageClass: "-"
  size: 20Gi

storageClass:
  defaultClass: true

nodeSelector:
  kubernetes.io/hostname: arch-k8s-cluster2-worker1
EOF
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm upgrade --install nfs-server-provisioner nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner -f ~/.k8s/sc/nfs-helm-values.yaml

# all nodes
pacman -S nfs-utils --noconfirm


# helm uninstall nfs-server-provisioner
# kubectl delete pv --all
# kubectl delete pvc --all
# kubectl delete sc --all
```

参考 <http://www.lishuai.fun/2021/08/12/k8s-nfs-pv/#/nfs-ganesha-server-and-external-provisioner> <https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs>

至此，集群基本部署完成。

## APISIX 部署

以下部分将使用 APISIX 作为 Ingress Controller，将集群内服务暴露至外部。

网关的选型有 Nginx, Traefik, Envoy 等。我选用了 APISIX。

安装 APISIX 网关及 Dashboard, Controller

```sh
helm repo add apisix https://charts.apiseven.com
helm repo update
# https://github.com/apache/apisix-helm-chart/blob/master/docs/en/latest/apisix.md
# https://github.com/apache/apisix-helm-chart/blob/master/charts/apisix
helm upgrade --install apisix apisix/apisix --set admin.allow.ipList={"0.0.0.0/0"} --set gateway.type=NodePort --set gateway.http.nodePort=30000 --set gateway.tls.enabled=true --set gateway.tls.nodePort=30001 --create-namespace --namespace apisix
# helm uninstall apisix --namespace apisix

# https://github.com/apache/apisix-helm-chart/blob/master/docs/en/latest/apisix-dashboard.md
# https://github.com/apache/apisix-helm-chart/tree/master/charts/apisix-dashboard
helm install apisix-dashboard apisix/apisix-dashboard --create-namespace --namespace apisix
# helm uninstall apisix-dashboard --namespace apisix

# https://github.com/apache/apisix-helm-chart/blob/master/docs/en/latest/apisix-ingress-controller.md
# https://github.com/apache/apisix-helm-chart/tree/master/charts/apisix-ingress-controller
helm install --set config.apisix.serviceNamespace=apisix apisix-ingress-controller apisix/apisix-ingress-controller --namespace ingress-apisix --create-namespace
# helm uninstall apisix-ingress-controller --namespace ingress-apisix
```

接下来部署 whoami 服务。whoami 会返回 HTTP 请求的一些信息，比较适合验证、调试。

在 master 节点准备 部署文件

```sh
mkdir -p ~/.k8s/whoami
cat>~/.k8s/whoami/whoami.yaml<<EOF
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
  # type: NodePort
  ports:
  - name: http
    targetPort: 80
    port: 80
    # nodePort: 30163
  selector:
    app: whoami
---
apiVersion: apisix.apache.org/v2beta3
kind: ApisixUpstream
metadata:
  name: whoami
spec:
  loadbalancer:
    type: ewma
---
apiVersion: apisix.apache.org/v2beta3
kind: ApisixRoute
metadata:
  name: whoami
spec:
  http:
  - name: whoami
    match:
      hosts:
      - whoami.r630-k8s.117503445.top
      paths:
      - "/"
    backends:
    - serviceName: whoami
      servicePort: 80
EOF
kubectl apply -f ~/.k8s/whoami
```

此时在浏览器中访问 <http://whoami.r630-k8s.117503445.top:30000> 即可访问到 whoami 服务。因为部署了 3 个实例，还可以通过多次访问，观察负载均衡带来的不同返回结果。

其中我将 `*.r630-k8s.117503445.top` 的 DNS 解析指向了 `192.168.2.160`。所以，访问 <http://whoami.r630-k8s.117503445.top:30000> 就会访问到 <http://192.168.2.160:30000>。 `30000` 端口上跑着 nodeport 类型的服务，流量顺利进入 APISIX。APISIX 通过 host 将流量再路由到特定的服务。如果以后还有 `service-a` 服务，就可以通过指定 <http://service-a.r630-k8s.117503445.top:30000> 作为 `service-a` 服务的访问入口。

## 参考

[ArchLinux下Kubernetes初体验--使用 kubeadm 创建一个单主集群](https://blog.firerain.me/article/22)
[Kubernetes - ArchWiki](https://wiki.archlinux.org/title/Kubernetes)
[在linux下安装Kubernetes](https://blog.haohtml.com/archives/30924)
[CNI](https://www.cni.dev/plugins/current/main/bridge/)
