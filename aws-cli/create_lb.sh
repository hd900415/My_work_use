#!/bin/bash
# 创建IAM策略
# 1. 下载 AWS Load Balancer Controller 的 IAM 策略，该策略允许负载均衡器代表您调用 AWS API。
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
# 2. 使用 AWS CLI 创建一个 IAM 策略，然后将该策略附加到一个 IAM 角色。
aws iam create-policy licy-nam \ 
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json
# {
#     "Policy": {
#         "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
#         "PolicyId": "ANPA2NK3X3IX5P6QPWLHT",
#         "Arn": "arn:aws:iam::715841329711:policy/AWSLoadBalancerControllerIAMPolicy",
#         "Path": "/",
#         "DefaultVersionId": "v1",
#         "AttachmentCount": 0,
#         "PermissionsBoundaryUsageCount": 0,
#         "IsAttachable": true,
#         "CreateDate": "2025-02-16T13:39:20+00:00",
#         "UpdateDate": "2025-02-16T13:39:20+00:00"
#     }
# }

# 创建IAM角色 请将 my-cluster 替换为您的集群的名称，将 111122223333 替换为您的账户 ID，然后运行命令。
# eksctl 模式安装
eksctl create iamserviceaccount \
--cluster=elk-hk-1-31-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--role-name AmazonEKSLoadBalancerControllerRole \
--attach-policy-arn=arn:aws:iam::715841329711:policy/AWSLoadBalancerControllerIAMPolicy \
--approve
# aws eks 模式安装
# a 检索集群的 OIDC 提供者 ID 并将其存储在变量中。
oidc_id=$(aws eks describe-cluster --name elk-hk-1-31-cluster --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
# b 确定您的账户中是否已存在具有您的集群 ID 的 IAM OIDC 提供者。您需要为集群和 IAM 配置 OIDC。
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4
