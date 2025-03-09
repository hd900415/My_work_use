#!/bin/bash
# 创建EKS集群
eksctl create cluster --name=eks-cluster --region=ap-east-1 --vpc-cidr=10.0.0.0/16 --zones=ap-east-1a,ap-east-1b,ap-east-1c --nodegroup-name=eks-cluster-ng-1 --node-type=m5.large --nodes=2 --nodes-min=2 --nodes-max=4 --node-volume-size=20 --node-volume-type=gp3 --ssh-access --ssh-public
# 创建nodegroup
eksctl create nodegroup --cluster=eks-cluster --region=ap-east-1 \
  --name=eks-cluster-hk-ng-1 \
  --node-type=m5.large \
  --nodes=2 \
  --nodes-min=2 \
  --nodes-max=4 \
  --node-volume-size=20 \
  --node-volume-type=gp3 \
  --node-zones=ap-east-1a,ap-east-1b,ap-east-1c \
  --ssh-access \
  --ssh-public-key=mingshengzhishang \
  --managed \
  --enable-ssm \
  --asg-access \
  --full-ecr-access \
  --alb-ingress-access \
  --install-neuron-plugin=false \
  --install-nvidia-plugin=false \
  --subnet-ids subnet-009210ff2c60cd7d3,subnet-0a421392815f6cda3,subnet-09336a4348acdd256

# 查看集群状态
eksctl get cluster --name=elk-cluster
# 查看nodegroup状态
eksctl get nodegroup --cluster=elk-cluster
# 获取集群配置
eksctl utils write-kubeconfig --cluster=elk-cluster

# 通过kubectl查看集群节点，并且使用ssh 
kubectl get nodes
# 调试模式有三种。legacy、pods、node
# 进行调试了。general模式是默认的模式，它会在节点上创建一个新的容器，这个容器会运行
# legacy模式是默认的模式，它会在节点上创建一个新的容器，这个容器会运行
# ephemeral-debug-agent，这个容器会挂载节点的根目录，这样就可以在节点上进行调试
# 一个类似于busybox的容器，这个容器会挂载节点的根目录，这样就可以在节点上
kubectl debug  node/ip-10-0-29-87.ap-east-1.compute.internal -it --image=amazonlinux --profile=general
# 安装软件
yum -y install amazon-efs-utils nfs-utils
# 更改时区
ln -sf /host/usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 设置时区
timedatectl set-timezone Asia/Shanghai
# 查看某一个节点的ID 
aws ec2 describe-instances  --filters "Name=private-dns-name,Values=ip-10-0-29-87.ap-east-1.compute.internal" --query "Reservations[*].Instances[*].InstanceId" --output table
# 查看所有的节点的ID和名字
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,PrivateDnsName]" --output table
aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output table
# 查看所有的节点的ID和自定义名称
aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value]" --output table
# 通过ssm连接到节点
# 安装ssm-agent 插件
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
yum install -y session-manager-plugin.rpm
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
dpkg -i session-manager-plugin.deb
# 通过ssm连接到节点
aws ssm start-session --target i-083f2da874403ee80 --region ap-east-1