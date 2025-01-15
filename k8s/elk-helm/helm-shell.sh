#!/bin/bash

# 设置命名空间
NAMESPACE="es"

# 创建命名空间
kubectl create namespace $NAMESPACE

# 创建 Elasticsearch 密码 Secret
kubectl create secret generic elasticsearch-secret -n $NAMESPACE \
  --from-literal=username=elastic \
  --from-literal=password=changeme

# 创建 Elasticsearch 证书 Secret
# 请将 <base64-encoded-certificate> 替换为实际的 base64 编码的证书内容
kubectl create secret generic elasticsearch-certificates -n $NAMESPACE \
  --from-literal=elastic-certificates.p12=<base64-encoded-certificate>

# 添加 Helm 仓库
helm repo add elastic https://helm.elastic.co

# 更新 Helm 仓库
helm repo update

# 使用 Helm 部署 Elasticsearch
helm install elasticsearch elastic/elasticsearch --namespace $NAMESPACE --version 8.5.0 \
  --set replicas=3 \
  --set image=docker.elastic.co/elasticsearch/elasticsearch:8.5.0 \
  --set resources.limits.cpu=2 \
  --set resources.limits.memory=8Gi \
  --set resources.requests.cpu=1 \
  --set resources.requests.memory=4Gi \
  --set volumeClaimTemplate.resources.requests.storage=50Gi \
  --set volumeClaimTemplate.storageClassName=nfs-storageclass \
  --set secretName=elasticsearch-secret \
  --set certificatesSecretName=elasticsearch-certificates

# 使用 Helm 部署 Kibana
helm install kibana elastic/kibana --namespace $NAMESPACE --version 8.5.0 \
  --set replicas=1 \
  --set image=docker.elastic.co/kibana/kibana:8.5.0 \
  --set resources.limits.cpu=1 \
  --set resources.limits.memory=2Gi \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=1Gi \
  --set volumeClaimTemplate.resources.requests.storage=50Gi \
  --set volumeClaimTemplate.storageClassName=nfs-storageclass \
  --set pluginsVolumeClaimTemplate.resources.requests.storage=5Gi \
  --set pluginsVolumeClaimTemplate.storageClassName=nfs-storageclass \
  --set elasticsearchHosts=https://elasticsearch:9200 \
  --set elasticsearch.username=elastic \
  --set elasticsearch.password=changeme \
  --set secretName=elasticsearch-secret

# 创建 Filebeat ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: filebeat-config
  namespace: $NAMESPACE
data:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*.log
      processors:
      - add_kubernetes_metadata:
          in_cluster: true

    output.elasticsearch:
      hosts: ['http://elasticsearch:9200']
      username: elastic
      password: changeme
EOF

# 部署 Filebeat DaemonSet
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
  namespace: $NAMESPACE
  labels:
    k8s-app: filebeat
spec:
  selector:
    matchLabels:
      k8s-app: filebeat
  template:
    metadata:
      labels:
        k8s-app: filebeat
    spec:
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:8.5.0
        volumeMounts:
        - name: config
          mountPath: /usr/share/filebeat/filebeat.yml
          subPath: filebeat.yml
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: filebeat-config
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
EOF