helm install redis bitnami/redis --namespace pt-dev \
--create-namespace \
--set auth.password=CcehTwJ7lcIkpwLxGbz6 \
--set global.storageClass=csi-disk \
--set architecture=replication \
--set cluster.enabled=true \
--set cluster.slaveCount=3 \
--set cluster.nodes=3 \
--set persistence.size=10Gi \
--set persistence.enabled=true \
--set master.persistence.size=10Gi \
--set replica.persistence.size=10Gi



helm install redis bitnami/redis --namespace pt \
--create-namespace \
--set auth.password=CcehTwJ7lcIkpwLxGbz6 \
--set global.storageClass=nfs-storageclass \
--set architecture=standalone \
--set cluster.enabled=false \
--set persistence.size=10Gi \
--set persistence.enabled=true 
