#!/bin/bash
set -e

# 设置变量
INSTANCE_NAME="your-instance-name"
NEW_INSTANCE_TYPE="t3.medium"  # 替换为desired的新实例类型

# 函数：执行AWS命令并检查结果
run_aws_command() {
    local cmd="$1"
    local description="$2"
    echo "Executing: $description"
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error: $description failed"
        echo "Command: $cmd"
        echo "Output: $output"
        exit $exit_code
    fi
    echo "Success: $description"
    echo "Output: $output"
    echo "------------------------"
}

# 获取实例ID
cmd="aws ec2 describe-instances --filters \"Name=tag:Name,Values=$INSTANCE_NAME\" --query 'Reservations[].Instances[].InstanceId' --output text"
run_aws_command "$cmd" "Get instance ID"
INSTANCE_ID=$output

if [ -z "$INSTANCE_ID" ]; then
    echo "Error: Instance not found"
    exit 1
fi

echo "Changing instance type for instance $INSTANCE_ID to $NEW_INSTANCE_TYPE"

# 停止实例
cmd="aws ec2 stop-instances --instance-ids $INSTANCE_ID"
run_aws_command "$cmd" "Stop instance"

# 等待实例停止
cmd="aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID"
run_aws_command "$cmd" "Wait for instance to stop"

# 更改实例类型
cmd="aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type '{\"Value\": \"$NEW_INSTANCE_TYPE\"}'"
run_aws_command "$cmd" "Modify instance type"

# 启动实例
cmd="aws ec2 start-instances --instance-ids $INSTANCE_ID"
run_aws_command "$cmd" "Start instance"

# 等待实例运行
cmd="aws ec2 wait instance-running --instance-ids $INSTANCE_ID"
run_aws_command "$cmd" "Wait for instance to start"

# 验证新的实例类型
cmd="aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[].Instances[].InstanceType' --output text"
run_aws_command "$cmd" "Verify new instance type"
NEW_TYPE=$output

echo "Instance type change complete"
echo "New instance type: $NEW_TYPE"