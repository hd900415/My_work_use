#!/bin/bash
#
helm repo add bitnami https://charts.bitnami.com/bitnami
helm pull oci://registry-1.docker.io/bitnamicharts/kafka --version 31.3.1



# 默认使用kraft mode

helm upgrade --install canal-kafka --namespace es  bitnami/kafka --version 31.3.1 \
--set replicaCount=3 \
--set global.defaultStorageClass="nfs-storageclass" \
--set kraft.enabled=true 
--set brokerConfig.auto.create.topics.enable=true \