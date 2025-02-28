#!/bin/bash
aws ec2 create-security-group --group-name Group --description "security group" --region eu-central-1
aws ec2 authorize-security-group-ingress --group-name Group --protocol tcp --port 22 --cidr 0.0.0.0/0 --region eu-central-1
aws ec2 authorize-security-group-ingress --group-name Group --protocol tcp --port 0-65535 --cidr 0.0.0.0/0 --region eu-central-1
aws ec2 authorize-security-group-ingress --group-name Group --protocol udp --port 0-65535 --cidr 0.0.0.0/0 --region eu-central-1
aws ec2 create-key-pair --key-name KeyPair --region eu-central-1
aws autoscaling create-auto-scaling-group --image-id ami-00d4a67fc1a5b8838 --key-name KeyPair --security-groups Group --instance-type c7g.medium --min-size 5 --max-size 5 --desired-capacity 5 --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=100}' --user-data fileb:///root/AWS-ARM-internetincome.sh --region eu-central-1
