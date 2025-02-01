#!/bin/bash
#
# Deploy CNI plugin
# 
# This script is used to deploy CNI plugin on the Kubernetes cluster.
# It is used by the `deploy_k8s.sh` script.
#
# Usage:
#   deploy_cni.sh <cni_plugin> <cni_version>
#
# Example:
#   deploy_cni.sh calico v3.8.2
#
# define variables
CNI_PLUGIN=$1
CNI_VERSION=$2
INTERFACE_NAME=$3

wget -q --show-progress --https-only --timestamping --no-check-certificate \
  "https://projectcalico.docs.tigera.io/archive/v3.25/manifests/calico.yaml"
# https://docs.projectcalico.org/manifests/calico.yaml

# https://calico-v3-25.netlify.app/archive/v3.25/manifests/calico.yaml
# 修改 calico.yaml 文件

  # vim calico.yaml
  #  在 - name: CLUSTER_TYPE 下方添加如下内容
  #  - name: CLUSTER_TYPE
  #   value: "k8s,bgp"
  #    下方为新增内容
  #  - name: IP_AUTODETECTION_METHOD
  #   value: "interface=网卡名称"
  #    INTERFACE_NAME=ens33
sed -i "s#interface=.*#interface=$INTERFACE_NAME#g" calico.yaml
sed -i "s#- name: IP_AUTODETECTION_METHOD#- name: CLUSTER_TYPE\n    value: \"k8s,bgp\"\n  - name: IP_AUTODETECTION_METHOD#g" calico.yaml
