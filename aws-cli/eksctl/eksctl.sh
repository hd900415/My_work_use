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