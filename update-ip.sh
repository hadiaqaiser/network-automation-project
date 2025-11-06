#!/bin/bash
# update-ip.sh — show EC2 public IP + handy commands

set -e

REGION="eu-west-1"
NAME_TAG="nsadmin-ca-web"

echo "🔍 Getting latest public IP from AWS..."

# 1) Find instance by tag
INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=$NAME_TAG" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
  echo "❌ Could not find instance with tag Name=$NAME_TAG in $REGION"
  exit 1
fi

# 2) Get its public IP
PUBLIC_IP=$(aws ec2 describe-instances --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "None" ]; then
  echo "❌ Instance has no public IP yet. Make sure it is running and has auto-assign public IP."
  exit 1
fi

echo
echo "🌐 Current EC2 public IP: $PUBLIC_IP"
echo
echo "🔑 SSH command:"
echo "ssh -i ~/.ssh/aws-edu-key ec2-user@$PUBLIC_IP"
echo
echo "💖 Website URL:"
echo "http://$PUBLIC_IP"