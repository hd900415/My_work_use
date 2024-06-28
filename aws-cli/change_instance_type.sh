#!/bin/bash

# 设置变量
INSTANCE_NAME="your-instance-name"
NEW_INSTANCE_TYPE="t3.medium"  # 替换为desired的新实例类型

# 获取实例ID
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" --query 'Reservations[].Instances[].InstanceId' --output text)

if [ -z "$INSTANCE_ID" ]; then
    echo "Error: Instance not found"
    exit 1
fi

echo "Changing instance type for instance $INSTANCE_ID to $NEW_INSTANCE_TYPE"

# 停止实例
echo "Stopping instance..."
aws ec2 stop-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID

# 更改实例类型
echo "Modifying instance type..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type "{\"Value\": \"$NEW_INSTANCE_TYPE\"}"

# 启动实例
echo "Starting instance..."
aws ec2 start-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# 验证新的实例类型
NEW_TYPE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].InstanceType' --output text)
echo "Instance type changed to: $NEW_TYPE"