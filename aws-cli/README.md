步骤 1：创建独立 VPC

1.创建 VPC
```shell
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-VPC}]"
```
记录返回的VPC_ID vpc-09a24e9962d985943

2.创建子网

2.1.公共子网（供 NAT 网关和 Master 使用）：
```shell
aws ec2 create-subnet --vpc-id vpc-09a24e9962d985943 --cidr-block 10.0.1.0/24  \
--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-PublicSubnet}]"
```
记录返回的 SubnetId  subnet-0b13c9564b2783613

2.2.私有子网（供 Node 使用）：
```shell
aws ec2 create-subnet --vpc-id vpc-09a24e9962d985943 --cidr-block 10.0.2.0/24 --availability-zone ap-east-1 \
--tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-PrivateSubnet}]"
```
记录返回的 SubnetId。 subnet-0e13643a874284dd8

3.创建并附加 Internet Gateway

```shell
aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-IGW}]"
```

网关ID  - igw-07873b821a996e5a2
```shell
aws ec2 attach-internet-gateway --vpc-id vpc-09a24e9962d985943 --internet-gateway-id igw-07873b821a996e5a2
```

4.- 创建路由表并关联子网

公共路由表（关联 Internet Gateway）：
```shell
aws ec2 create-route-table --vpc-id vpc-09a24e9962d985943 \
--tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-PublicRT}]"
-------rtb-0c94c169ced2e833b 

aws ec2 create-route --route-table-id rtb-0c94c169ced2e833b --destination-cidr-block 0.0.0.0/0 --gateway-id igw-07873b821a996e5a2

aws ec2 associate-route-table --route-table-id rtb-0c94c169ced2e833b --subnet-id subnet-0b13c9564b2783613
```

私有路由表（关联 NAT 网关）： 创建 NAT 网关并获取其 NatGatewayId：

```shell
ALLOC_ID=$(aws ec2 allocate-address --query "AllocationId" --output text)

aws ec2 create-nat-gateway --subnet-id subnet-0b13c9564b2783613 --allocation-id $ALLOC_ID \
--tag-specifications "ResourceType=natgateway,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-NATGW}]"
----nat-002bf05993f415f2d

aws ec2 wait nat-gateway-available --nat-gateway-ids nat-002bf05993f415f2d
```

配置私有子网路由表：

```shell
aws ec2 create-route-table --vpc-id vpc-09a24e9962d985943 \
--tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-PrivateRT}]"

aws ec2 create-route --route-table-id rtb-019422450f32b5a82 --destination-cidr-block 0.0.0.0/0 --nat-gateway-id nat-002bf05993f415f2d

aws ec2 associate-route-table --route-table-id rtb-019422450f32b5a82 --subnet-id subnet-0e13643a874284dd8
```

步骤 2：创建 Master 节点

1.启动 Master 实例
```shell
aws ec2 run-instances \
--image-id ami-09a6ac7a83c9b4224 \
--count 1 \
--instance-type c5.2xlarge \
--key-name miaoqu \
--security-group-ids sg-063698b0fc500f9de \
--subnet-id subnet-0b13c9564b2783613 \
--block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":200,\"VolumeType\":\"gp3\"}}]" \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-Master}]"
```

记录返回的实例 ID i-011beba7ab62ff9f7

2 为 Master 分配弹性 IP

```shell
ALLOC_ID=$(aws ec2 allocate-address --query "AllocationId" --output text)
aws ec2 associate-address --instance-id i-011beba7ab62ff9f7 --allocation-id $ALLOC_ID
```

3. 配置安全组

```shell
aws ec2 authorize-security-group-ingress --group-id sg-063698b0fc500f9de \
--protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-063698b0fc500f9de \
--protocol tcp --port 6443 --cidr 0.0.0.0/0
```

步骤 3：创建 Node 节点

1.启动 Node 实例
```shell
aws ec2 run-instances \
  --image-id ami-09a6ac7a83c9b4224 \
  --count 3 \
  --instance-type c5.2xlarge \
  --key-name miaoqu \
  --security-group-ids sg-0c99a5c3f16d5d2df \
  --subnet-id subnet-0e13643a874284dd8 \
  --block-device-mappings "[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":200,\"VolumeType\":\"gp3\"}}]" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=MiaoQu-Prod-K8S-HK-Node}]"
```

2. 配置 Node 的安全组
允许集群内部通信：
```shell
aws ec2 authorize-security-group-ingress --group-id sg-0c99a5c3f16d5d2df \
--protocol all --source-group sg-063698b0fc500f9de
aws ec2 authorize-security-group-ingress --group-id sg-0c99a5c3f16d5d2df \
--protocol all --source-group sg-0c99a5c3f16d5d2df
```


