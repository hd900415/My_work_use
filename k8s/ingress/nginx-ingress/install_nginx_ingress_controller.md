  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: nginx-ingress
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls

#  模板
helm upgrade ingress-nginx --namespace ingress-nginx --create-namespace --debug --wait --install --atomic \
   --set controller.kind="Deployment" \
   --set controller.replicaCount="3" \
   --set controller.minAvailable="1" \
   --set controller.image.registry="docker.io" \
   --set controller.image.image="kubelibrary/ingress-nginx-controller" \
   --set controller.image.tag="v1.5.1" \
   --set controller.image.digest="" \
   --set controller.ingressClassResource.name="nginx" \
   --set controller.ingressClassResource.enable="true" \
   --set controller.ingressClassResource.default="false" \
   --set controller.service.enabled="true" \
   --set controller.service.type="NodePort" \
   --set controller.service.enableHttps="false" \
   --set controller.service.nodePorts.http="32080" \
   --set controller.service.nodePorts.https="32443" \
   --set controller.admissionWebhooks.enabled="true" \
   --set controller.admissionWebhooks.patch.image.registry="docker.io" \
   --set controller.admissionWebhooks.patch.image.image="kubelibrary/kube-webhook-certgen" \
   --set controller.admissionWebhooks.patch.image.tag="v20220916-gd32f8c343" \
   --set controller.admissionWebhooks.patch.image.digest="" \
   --set controller.metrics.enabled="true" \
   --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
   --set-string controller.podAnnotations."prometheus\.io/port"="10254" \
   --set defaultBackend.enabled="true" \
   --set defaultBackend.name="defaultbackend" \
   --set defaultBackend.image.registry="docker.io" \
   --set defaultBackend.image.image="kubelibrary/defaultbackend-amd64" \
   --set defaultBackend.image.tag="1.5" \
   --set defaultBackend.replicaCount="1" \
   --set defaultBackend.minAvailable="1" \
   --set rbac.create="true" \
   --set serviceAccount.create="true" \
   --set podSecurityPolicy.enabled="true" \
   ./ingress-nginx-4.4.2.tgz
注意如下参数
controller.service.enableHttps  //是否打开https，如果ingress前有Nginx或者七层LB，这里可以设置为false
controller.ingressClassResource.name  //ingressclass的名称，根据自己的需求修改
controller.replicaCount  //pod数量,根据节点数量自行调整s




#  实际应用 

helm install ingress-nginx --namespace ingress-nginx --create-namespace --debug --wait --install --atomic \
   --set controller.kind="Deployment" \
   --set controller.replicaCount="3" \
   --set controller.minAvailable="1" \
   --set controller.ingressClassResource.name="nginx" \
   --set controller.ingressClassResource.enable="true" \
   --set controller.ingressClassResource.default="false" \
   --set controller.service.enabled="true" \
   --set controller.service.type="NodePort" \
   --set controller.service.enableHttps="true" \
   --set controller.service.nodePorts.http="80" \
   --set controller.service.nodePorts.https="443" \
   --set controller.admissionWebhooks.enabled="true" \
   --set controller.metrics.enabled="true" \
   --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
   --set-string controller.podAnnotations."prometheus\.io/port"="10254" \
   --set defaultBackend.enabled="true" \
   --set defaultBackend.name="defaultbackend" \
   --set defaultBackend.replicaCount="1" \
   --set defaultBackend.minAvailable="1" \
   --set rbac.create="true" \
   --set serviceAccount.create="true" \
   --set podSecurityPolicy.enabled="true" \


   helm install   ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx \
   --set controller.kind="Deployment"    \
   --set controller.replicaCount="3"    \
   --set controller.minAvailable="1"    \
   --set controller.ingressClassResource.name="nginx"    \
   --set controller.ingressClassResource.enable="true"    \
   --set controller.ingressClassResource.default="false"   \
   --set controller.service.enabled="true"    \
   --set controller.service.type="NodePort"    \
   --set controller.service.enableHttps="true"    \
   --set controller.service.nodePorts.http="80"    \
   --set controller.service.nodePorts.https="443"    \
   --set controller.admissionWebhooks.enabled="true"    \
   --set controller.metrics.enabled="true"    \
   --set-string controller.podAnnotations."prometheus\.io/scrape"="true"    \
   --set-string controller.podAnnotations."prometheus\.io/port"="10254"    \
   --set defaultBackend.enabled="true"    \
   --set defaultBackend.name="defaultbackend"    \
   --set defaultBackend.replicaCount="1"    \
   --set defaultBackend.minAvailable="1"    \
   --set rbac.create="true"   \
   --set serviceAccount.create="true"   \
   --set podSecurityPolicy.enabled="true"




## 简单通过bitnami安装
helm upgrade --install nginx-ingress-controller bitnami/nginx-ingress-controller --namespace nginx-ingress  --create-namespace  \
--set controller.service.type="LoadBalancer" \
--set controller.ingressClassResource.name="nginx" \
--set controller.ingressClassResource.enable="true" \
--set controller.ingressClassResource.default="false" \
--set controller.replicaCount="3" \
--set controller.service.enableHttps="true" \
--set controller.service.nodePorts.http="80" \
--set controller.service.nodePorts.https="443" \
--set controller.service.loadBalancerIP="192.168.1.200"