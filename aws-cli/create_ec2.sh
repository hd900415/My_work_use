#!/bin/bash

# 创建VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=prod
echo "VPC created with ID: $VPC_ID"

# 创建子网
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=prod-subnet
echo "Subnet created with ID: $SUBNET_ID"

# 创建互联网网关并附加到VPC
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
echo "Internet Gateway created with ID: $IGW_ID and attached to VPC"

# 创建路由表并添加路由
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $ROUTE_TABLE_ID
echo "Route table created and associated with subnet"

# 创建安全组
SG_ID=$(aws ec2 create-security-group --group-name prod --description "prod security group" --vpc-id $VPC_ID --query 'GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "Security group created with ID: $SG_ID"

# 创建EC2实例
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0de566aa7b182e06e \
    --count 1 \
    --instance-type t2.micro \
    --key-name wtai \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=prod}]' \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":100,"VolumeType":"gp3"}}]' \
    --query 'Instances[0].InstanceId' \
    --output text)
echo "EC2 instance created with ID: $INSTANCE_ID"

# 等待实例运行
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "EC2 instance is running"

# 创建弹性IP
ELASTIC_IP=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
echo "Elastic IP allocated with ID: $ELASTIC_IP"

# 将弹性IP绑定到实例
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ELASTIC_IP

# 获取弹性IP地址
EIP_ADDRESS=$(aws ec2 describe-addresses --allocation-ids $ELASTIC_IP --query 'Addresses[0].PublicIp' --output text)

echo "Elastic IP associated with the instance. IP address: $EIP_ADDRESS"
echo "You can now connect to your instance using: ssh -i wtai.pem ec2-user@$EIP_ADDRESS"