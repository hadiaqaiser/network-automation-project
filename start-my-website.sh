#!/bin/bash
# 🌸 One-click startup for Hadia's website
# Does:
# 1) Find EC2 by tag Name=nsadmin-ca-web
# 2) Start it if stopped
# 3) Copy app from Mac -> EC2
# 4) Build + run Docker container on port 80
# 5) Open site in browser

set -e

REGION="eu-west-1"
KEY_PATH="$HOME/.ssh/aws-edu-key"
PROJECT="$HOME/Desktop/network-automation-project"
LOCAL_APP="$PROJECT/app"
REMOTE_APP="/home/ec2-user/app"
NAME_TAG="nsadmin-ca-web"

say() { echo -e "$@"; }

say "🔎 Finding EC2 instances by tag Name=$NAME_TAG ..."

INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=$NAME_TAG" \
            "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query "Reservations[0].Instances[0].InstanceId" --output text)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
  say "❌ No EC2 instance found with tag Name=$NAME_TAG in $REGION."
  exit 1
fi

STATE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].State.Name" --output text)

say "✅ Using instance: $INSTANCE_ID (state: $STATE)"

if [[ "$STATE" == "stopped" ]]; then
  say "🔹 Starting EC2 instance..."
  aws ec2 start-instances --region "$REGION" --instance-ids "$INSTANCE_ID" >/dev/null
fi

say "⏳ Waiting for EC2 to be running..."
aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"

IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

if [[ -z "$IP" || "$IP" == "None" ]]; then
  say "❌ Could not get public IP. Check subnet / public IP settings."
  exit 1
fi

say "🌐 EC2 public IP: $IP"

# Make sure HTTP 80 is open
SG=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true

aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG" \
  --ip-permissions 'IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges=[{CidrIpv6="::/0"}]' 2>/dev/null || true

# Clean remote app dir and copy fresh files
say "🧹 Cleaning remote app folder..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$IP" "rm -rf $REMOTE_APP && mkdir -p $REMOTE_APP"

say "📤 Copying app files to EC2..."
scp -i "$KEY_PATH" -r "$LOCAL_APP/"* ec2-user@"$IP":"$REMOTE_APP/"

say "🐳 Rebuilding and starting Docker app..."
ssh -i "$KEY_PATH" ec2-user@"$IP" bash << 'REMOTE'
set -e
sudo yum install -y docker >/dev/null 2>&1 || true
sudo systemctl enable --now docker

cd /home/ec2-user/app

sudo docker rm -f nsadmin-app 2>/dev/null || true
sudo docker build -t nsadmin-app .
sudo docker run -d --name nsadmin-app -p 80:3000 nsadmin-app

sudo docker ps
REMOTE

say "✅ Done. Opening your site…"
open "http://$IP"
say "🎀 Live at: http://$IP"