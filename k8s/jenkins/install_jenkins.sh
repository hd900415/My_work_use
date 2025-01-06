helm repo add jenkins https://charts.jenkins.io
helm repo update



helm install jenkins \
  --namespace jenkins --create-namespace \
  --set controller.image=haidao900/jenkins:lts-jdk17-mvn399 \
  --set persistence.existingClaim=jenkins-pvc \
  --set controller.serviceType=NodePort \
  --set controller.service.nodePort=32000 \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=1Gi \
  --set password=admin \
  --set rbac.create=true \
  --set serviceAccount.create=true \
  --set serviceAccount.name=jenkins \
./values.yaml
