cat <<EOF > mysql-config.cnf
> [mysqld]
> lower_case_table_names=1
EOF
> EOF
kubectl create configmap mysql-config --from-file=mysql-config.cnf -n pt-dev
helm install mysql8 -f values.yaml -n pt-dev bitnami/mysql

helm repo add bitnami https://charts.bitnami.com/bitnami