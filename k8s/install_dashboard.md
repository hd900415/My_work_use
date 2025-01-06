rancher or kube dashboard or kube-sphere


# dashbord
wget  https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# 编辑sa 访问方式NodePort 

# 参考 dashboard-admin.yaml 进行 创建 sa 和secrets 

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







[root@k8s-master dashbord]# kubectl -n kubernetes-dashboard create token kubernetes-dashboard-sa
eyJhbGciOiJSUzI1NiIsImtpZCI6IjZWV1FrclRSUndLYmRpNjlwckdsbUtFSDQwc3FDUTV5MUhTLTBGalIyQ2cifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzM1ODYwMzMwLCJpYXQiOjE3MzU4NTY3MzAsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiODQzNzQwMDEtMzMxYy00NmY5LWE2MjAtM2E4NDBlYmNjZDFiIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC1zYSIsInVpZCI6IjU5OGViN2E1LTVkNTgtNDE0NC04ZWNmLTFiZjMzM2I1MjIwOSJ9fSwibmJmIjoxNzM1ODU2NzMwLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQtc2EifQ.JxSZkuuf1uoLHsqoEggzAZ_DCOUS3K4a4ID-wFtVFI0ISzyAfuHJ7ViNDit5Up421XnaysjBrJNY1ANyVo-EenBckpPReYyNHgD42e7gDojdwPPYZbBLhRiwS0WEF7tIAzNLeA-CawLbK304BbRn__3egMVcxg5uFW_NXH2n9W_65OQArEuK-27eXySV-KpDgjVdGqAKbEVL4MNeRl20-LTFzTsDtzP_K_LEva9ZmX_f4Qwm69vbgADUD7JAFhydEQdsEXPSlA74IyxjErNxg2_U1euuB3p5dvXOOvDc7PdUbUGANoh5NB5wjFiXabjF4k0yl_L8HTm-VfpNVsetXg
