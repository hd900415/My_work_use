rancher or kube dashboard or kube-sphere

#### dashbord
`wget  https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
`
#### 编辑sa 访问方式NodePort 

#### 参考 dashboard-admin.yaml 进行 创建 sa 和secrets 
```
[root@k8s-master dashbord]# cat kubernetes-dashboard-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard-sa
  namespace: kubernetes-dashboard

[root@k8s-master dashbord]# cat kubernetes-dashboard-sa-binding.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-sa-binding
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard-sa
    namespace: kubernetes-dashboard
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```






`[root@k8s-master dashbord]# kubectl -n kubernetes-dashboard create token kubernetes-dashboard-sa
`