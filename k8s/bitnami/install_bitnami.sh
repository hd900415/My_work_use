helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm pull bitnami/wordpress --untar --version 10.0.0
