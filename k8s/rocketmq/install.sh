# https://rocketmq.apache.org/zh/docs/quickStart/04quickstartWithHelmInKubernetes/


#验证消息发送和接收
#使用 mqadmin 工具创建 Topic和消费者。


# 登录 pod 内
$ kubectl exec -ti rocketmq-demo-broker-0  -- /bin/bash

# 通过 mqadmin 创建 Topic
$ sh mqadmin updatetopic  -t TestTopic -c DefaultCluster

# 通过 mqadmin 创建订阅组
$ sh mqadmin updateSubGroup -c DefaultCluster -g TestGroup





https://blog.csdn.net/tingting0119/article/details/140440867


helm repo add rocketmq https://helm-charts.itboon.top/rocketmq 
helm repo up
helm search repo rocketmq
helm pull rocketmq/rocketmq-cluster --version 11.4.0

helm upgrade --install rocketmq rocketmq/rocketmq-cluster \
-n pt \
--create-namespace \
--set rocketmq.namesrv.resources.requests.memory=1Gi \
--set rocketmq.namesrv.resources.requests.cpu=500m \
--set rocketmq.broker.resources.requests.memory=1Gi \
--set rocketmq.broker.resources.requests.cpu=500m \
--set rocketmq.broker.resources.limits.memory=2Gi \
--set rocketmq.broker.resources.limits.cpu=1 \
--set rocketmq.broker.replicas=2 \
--set rocketmq.broker.storageClass=nfs-storageclass \
--set broker.config.enableLmq=true \
--set broker.config.enableMultiDispatch=true



helm upgrade --install rocketmq rocketmq/rocketmq-cluster \
-n pt \
--create-namespace \
--set rocketmq.namesrv.resources.requests.memory=1Gi \
--set rocketmq.namesrv.resources.requests.cpu=500m \
--set rocketmq.broker.resources.requests.memory=1Gi \
--set rocketmq.broker.resources.requests.cpu=500m \
--set rocketmq.broker.resources.limits.memory=2Gi \
--set rocketmq.broker.resources.limits.cpu=1 \
--set rocketmq.broker.replicas=2 \
--set rocketmq.broker.storageClass=nfs-storageclass \
--set broker.config.enableLmq=true \
--set broker.config.enableMultiDispatch=true \
--set proxy.service.type=NodePort \
--set proxy.enabled=true  \
--set namesrv.service.type=NodePort \
--set namesrv.enabled=true \
--set dashboard.enabled=true \
--set dashboard.service.type=NodePort \
--set namesrv.service.type=NodePort \
--set broker.service.type=NodePort \
--set broker.ip=192.168.1.72 \
--set namesrv.ip=192.168.1.72 


# bitnami/rocketmq 

helm repo add rocketmq-repo https://helm-charts.itboon.top/rocketmq
helm repo update rocketmq-repo

helm upgrade --install rocketmq \
  --namespace pt \
  --create-namespace \
  --set broker.size.master="3" \
  --set broker.master.jvm.maxHeapSize="2G" \
  --set broker.master.resources.requests.memory="4Gi" \
  --set proxy.service.type=NodePort \
  --set proxy.enabled=true \
  --set broker.master.resources.requests.cpu="1" \
  --set broker.master.resources.limits.cpu="2" \
  --set broker.master.resources.limits.memory="8Gi" \
  --set broker.master.storageClass=nfs-storageclass \
  --set broker.master.persistence.enabled=true \
  --set broker.master.persistence.size="10Gi" \
  --set broker.master.persistence.storageClass=nfs-storageclass \
  --set broker.master.persistence.accessMode=ReadWriteMany \
  rocketmq-repo/rocketmq-cluster
