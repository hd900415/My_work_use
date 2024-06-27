#!/bin/bash
set -e  # 遇到错误时立即退出
set -u # 使用未定义的变量时报错.


# 设置变量
VPC_NAME="prod"
SUBNET_NAME="prod-subnet"
NEW_INSTANCE_NAME="prod-new"  # 新实例的名称
NEW_SG_NAME="prod-new-sg"     # 新安全组的名称
INSTANCE_TYPE="c5.2xlarge"      # 可以根据需要更改实例类型
KEY_NAME="wtai"
AMI_ID="ami-0de566aa7b182e06e"

# 获取已存在的VPC ID
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query 'Vpcs[0].VpcId' --output text)
VPC_ID=$(echo $VPC_ID | tr -d '[:space:]')
if [ -z "$VPC_ID" ]; then
    echo "Error: VPC with name $VPC_NAME not found"
    exit 1
fi
echo "Using existing VPC: $VPC_ID"

# 获取已存在的子网 ID
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$SUBNET_NAME" --query 'Subnets[0].SubnetId' --output text)
if [ -z "$SUBNET_ID" ]; then
    echo "Error: Subnet with name $SUBNET_NAME not found in VPC $VPC_ID"
    exit 1
fi
echo "Using existing Subnet: $SUBNET_ID"

# 创建新的安全组
SG_ID=$(aws ec2 create-security-group --group-name $NEW_SG_NAME --description "New security group for $NEW_INSTANCE_NAME" --vpc-id $VPC_ID --query 'GroupId' --output text)
SG_ID=$(echo $SG_ID | tr -d '[:space:]')
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "New Security group created with ID: $SG_ID"

if ! [[ $VPC_ID =~ ^vpc-[a-f0-9]+$ ]]; then
    echo "Error: Invalid VPC ID format: $VPC_ID"
    exit 1
fi

# 检查VPC是否存在
if ! aws ec2 describe-vpcs --vpc-ids "$VPC_ID" >/dev/null 2>&1; then
    echo "Error: VPC with ID $VPC_ID does not exist"
    exit 1
fi

# 创建新的EC2实例
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NEW_INSTANCE_NAME}]" \
    --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":100,"VolumeType":"gp3"}}]' \
    --query 'Instances[0].InstanceId' \
    --output text)
echo "New EC2 instance created with ID: $INSTANCE_ID"

# 等待实例运行
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "EC2 instance is running"

# 创建新的弹性IP
ELASTIC_IP=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
echo "New Elastic IP allocated with ID: $ELASTIC_IP"

# 将新的弹性IP绑定到实例
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ELASTIC_IP

# 获取弹性IP地址
EIP_ADDRESS=$(aws ec2 describe-addresses --allocation-ids $ELASTIC_IP --query 'Addresses[0].PublicIp' --output text)

echo "Elastic IP associated with the new instance. IP address: $EIP_ADDRESS"
echo "You can now connect to your new instance using: ssh -i $KEY_NAME.pem ec2-user@$EIP_ADDRESS"