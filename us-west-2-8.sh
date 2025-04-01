#!/bin/bash

# Cấu hình AWS Region
AWS_REGION="us-west-2"
KEY_PAIR_NAME="KeyPair"
SECURITY_GROUP_NAME="Group"
LAUNCH_TEMPLATE_NAME="MyLaunchTemplate"
ASG_NAME="AutoScaling-$AWS_REGION"
AMI_ID="ami-058140b4ea0516c42"
INSTANCE_TYPE="c6g.medium"
USER_DATA_SCRIPT="/root/AWS-ARM-internetincome.sh"
VOLUME_SIZE=100
MIN_SIZE=8
MAX_SIZE=8
DESIRED_CAPACITY=8

# Tạo Security Group
aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Security group for Auto Scaling" --region $AWS_REGION

# Thiết lập quy tắc Ingress cho Security Group
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 0-65535 --cidr 0.0.0.0/0 --region $AWS_REGION
aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol udp --port 0-65535 --cidr 0.0.0.0/0 --region $AWS_REGION

# Tạo Key Pair
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --region $AWS_REGION

# Lấy VPC ID mặc định
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text --region $AWS_REGION)

# Lấy danh sách tất cả Subnet ID trong VPC
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text --region $AWS_REGION | tr '\t' ',')

# Lấy Security Group ID
SG_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$SECURITY_GROUP_NAME" --query "SecurityGroups[0].GroupId" --output text --region $AWS_REGION)

echo "VPC ID: $VPC_ID"
echo "Subnet IDs: $SUBNET_IDS"
echo "Security Group ID: $SG_ID"

# Tạo Launch Template
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template     --launch-template-name $LAUNCH_TEMPLATE_NAME     --version-description "Initial version"     --launch-template-data "{
        \"ImageId\": \"$AMI_ID\",
        \"InstanceType\": \"$INSTANCE_TYPE\",
        \"KeyName\": \"$KEY_PAIR_NAME\",
        \"SecurityGroupIds\": [\"$SG_ID\"],
        \"UserData\": \"$(base64 -w 0 $USER_DATA_SCRIPT)\",
        \"BlockDeviceMappings\": [{
            \"DeviceName\": \"/dev/sda1\",
            \"Ebs\": {\"VolumeSize\": $VOLUME_SIZE}
        }]
    }"     --query "LaunchTemplate.LaunchTemplateId"     --output text     --region $AWS_REGION)

echo "Launch Template $LAUNCH_TEMPLATE_NAME đã được tạo với ID: $LAUNCH_TEMPLATE_ID."

# Tạo Auto Scaling Group với Launch Template
aws autoscaling create-auto-scaling-group     --auto-scaling-group-name $ASG_NAME     --launch-template "LaunchTemplateId=$LAUNCH_TEMPLATE_ID,Version=1"     --min-size $MIN_SIZE     --max-size $MAX_SIZE     --desired-capacity $DESIRED_CAPACITY     --vpc-zone-identifier "$SUBNET_IDS"     --region $AWS_REGION

echo "Auto Scaling Group $ASG_NAME đã được tạo."
