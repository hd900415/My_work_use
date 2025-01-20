#!/bin/bash
#
# This script will create a new namespace and deploy the metrics-server
# to the new namespace.
#
# Usage:
# wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml

# 修改metrics-server.yaml文件 忽略证书检查
kubectl apply -f metrics-server.yaml