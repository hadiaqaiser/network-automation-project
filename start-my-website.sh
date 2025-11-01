#!/bin/bash
# 🌸 One-click startup for Hadia's website (auto-discovers your instance)

set -e

REGION="eu-west-1"
KEY_PATH="$HOME/.ssh/aws-edu-key"
LOCAL_APP="$HOME/Desktop/network-automation-project/app"
REMOTE_APP="/home/ec2-user/app"
NAME_TAG="nsadmin-ca-web"

say() { echo -e "$@"; }

say "🔎 Finding EC2 instance by tag Name=$NAME_TAG ..."
INSTANCE_ID=$(aws ec2 describe-instances --region "$REGION" \
  --filters "Name=tag:Name,Values=$NAME_TAG" \
  --query "Reservations[0].Instances[0].InstanceId" --output text)

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
  say "❌ No instance found with tag Name=$NAME_TAG in $REGION. Create or tag it, then retry."
  exit 1
fi

STATE=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].State.Name" --output text)
say "✅ Instance: $INSTANCE_ID (state: $STATE)"

if [[ "$STATE" == "stopped" ]]; then
  say "🔹 Starting EC2 instance..."
  aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$REGION" >/dev/null
fi

say "⏳ Waiting for EC2 to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

IP=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
if [[ -z "$IP" || "$IP" == "None" ]]; then
  say "❌ Could not get public IP. Is the instance in a public subnet with a public IP?"
  exit 1
fi
say "🌐 EC2 public IP: $IP"

# Ensure security group has HTTP open (IPv4 + IPv6), ignore errors if already open
SG=$(aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG" --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true
aws ec2 authorize-security-group-ingress --region "$REGION" --group-id "$SG" \
  --ip-permissions 'IpProtocol=tcp,FromPort=80,ToPort=80,Ipv6Ranges=[{CidrIpv6="::/0"}]' 2>/dev/null || true

# Make sure remote app dir exists
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ec2-user@"$IP" "mkdir -p $REMOTE_APP"

# Sync app (fresh copy so HTML never corrupts)
say "📤 Copying app files to EC2..."
scp -i "$KEY_PATH" -r "$LOCAL_APP/" ec2-user@"$IP":"$REMOTE_APP/"

# Ensure index.html is under /public
ssh -i "$KEY_PATH" ec2-user@"$IP" "mkdir -p $REMOTE_APP/public; [[ -f $REMOTE_APP/index.html ]] && mv -f $REMOTE_APP/index.html $REMOTE_APP/public/index.html || true"

# Rebuild & run container
say "🐳 Rebuilding and starting Docker app..."
ssh -i "$KEY_PATH" ec2-user@"$IP" bash <<'REMOTE'
set -e
sudo yum install -y docker >/dev/null 2>&1 || true
sudo systemctl enable --now docker
cd /home/ec2-user/app
docker rm -f nsadmin-app 2>/dev/null || true
docker build -t nsadmin-app .
docker run -d --name nsadmin-app -p 80:3000 nsadmin-app
REMOTE

say "✅ Done. Opening your site…"
open "http://$IP"

say "🎀 Live at: http://$IP"