#!/bin/bash
aws ec2 create-security-group --group-name Group --description "security group" --region eu-west-3
aws ec2 authorize-security-group-ingress --group-name Group --protocol tcp --port 22 --cidr 0.0.0.0/0 --region eu-west-3
aws ec2 authorize-security-group-ingress --group-name Group --protocol tcp --port 0-65535 --cidr 0.0.0.0/0 --region eu-west-3
aws ec2 authorize-security-group-ingress --group-name Group --protocol udp --port 0-65535 --cidr 0.0.0.0/0 --region eu-west-3
aws ec2 create-key-pair --key-name KeyPair --region eu-west-3
aws autoscaling create-auto-scaling-group --image-id ami-0e1e669f1f5062039 --key-name KeyPair --security-groups Group --instance-type c6g.medium --min-size 5 --max-size 5 --desired-capacity 5 --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=100}' --user-data fileb:///root/AWS-ARM-internetincome.sh --region eu-west-3
