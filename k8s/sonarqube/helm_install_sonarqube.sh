helm upgrade --install  sonarqube  sonarqube/sonarqube-lts \
    --namespace sonar --create-namespace \
    --set initSysctl.enabled="false" \
    --set initFs.enabled="false" \
    --set nginx.enabled="false" \
    --set elasticsearch.enabled=true \
    --set elasticsearch.hosts[0]="http://elasticsearch-headless.es.svc.cluster.local:9200" \
    --set elasticsearch.username="elastic" \
    --set elasticsearch.password="aGlE3w56z0abFNFflIs5"



kubectl create namespace cert-manager
kubectl repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager --create-namespace \
    --version v1.13.3 \
    --set ingressShim.defaultIssuerName=letsencrypt-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    --set installCRDs=true 

