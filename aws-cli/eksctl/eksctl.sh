#!/bin/bash
# 创建EKS集群
eksctl create cluster --name new-eks-cluster --region ap-east-1 \
  --version 1.31 \ # 指定Kubernetes版本
  --vpc-nat-mode HighlyAvailable \  # 启用多可用区 NAT 网关
  --zones ap-east-1a,ap-east-1b,ap-east-1c \
  --without-nodegroup  # 先仅创建 VPC
# 创建nodegroup
eksctl create nodegroup --cluster=eks-cluster-hk --region=ap-east-1 \
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
  --install-nvidia-plugin=false 

# 查看集群状态
eksctl get cluster --name=elk-hk-1-31-cluster
# 查看nodegroup状态
eksctl get nodegroup --cluster=elk-hk-1-31-cluster