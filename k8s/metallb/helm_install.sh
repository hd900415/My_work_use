#!/bin/bash
#
# Install MetalLB using Helm
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm repo add metallb https://charts.bitnami.com/bitnami
helm  upgrade  --install metallb bitnami/metallb --namespace metallb-system --create-namespace



#命令	作用
kubectl get ipaddresspools -n metallb-system	#列出所有地址池
kubectl describe ipaddresspool my-ip-pool -n metallb-system	#查看具体地址池详情
kubectl get ipaddresspools -n metallb-system -o yaml	#以 YAML 形式查看地址池
kubectl get svc -A	|grep LoadBalancer
kubectl get pods -n metallb-system	#检查 MetalLB Controller 和 Speaker 状态
kubectl get l2advertisements -n metallb-system	#查看 L2Advertisement 配置
# 使用 Kubectl 安装 

# 原生
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
# 启用 FRR
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-frr.yaml


#BGP 模式 
#1）配置 BGPPeer

#需要为每个需要连接的路由器都创建一个 BGPPeer 实例，这样 MetalLB 才能与 BGP 路由器建立会话。BGPPeer 实例的配置如下：
cat <<EOF > BGPPeer.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  name: sample
  namespace: metallb-system
spec:
  myASN: 64500 # MetalLB 使用的 AS 号
  peerASN: 64501 # 路由器的 AS 号
  peerAddress: 10.0.0.1 # 路由器地址
EOF

kubectl apply -f BGPPeer.yaml
#2）创建 IPAdressPool
cat <<EOF > IPAddressPool.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250 # 可分配的 IP 地址
EOF

kubectl apply -f IPAddressPool.yaml
#3）创建 L2Advertisement，并关联 IPAdressPool
#如果不设置关联到 IPAdressPool，那默认 L2Advertisement 会关联上所有可用的 IPAdressPool。
#也可以使用标签选择器来筛选需要关联的 IPAdressPool 列表。
cat <<EOF > L2Advertisement.yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

kubectl apply -f  L2Advertisement.yaml
#启动 FRR 作为 BGP 的后端，不需要额外的配置，只是在安装的时候会创建不同的 CR。启动 FRR 模式后，需要用到某些特性要单独进行配置。