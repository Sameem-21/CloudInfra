#!/bin/bash
set -euo pipefail

INSTANCE_ID=${INSTANCE_ID:-}
PUBLIC_IP=${PUBLIC_IP:-}
AZ=${AZ:-}
USER="ubuntu"

echo "📋 Terraform outputs:"
echo "INSTANCE_ID=$INSTANCE_ID"
echo "PUBLIC_IP=$PUBLIC_IP"
echo "AZ=$AZ"

if [[ -z "$INSTANCE_ID" || -z "$PUBLIC_IP" || -z "$AZ" ]]; then
  echo "❌ ERROR: Missing required Terraform outputs."
  exit 1
fi

KEY_PATH="$HOME/.ssh/temp-key"
if [ ! -f "$KEY_PATH" ]; then
  echo "🔑 Generating temporary SSH key..."
  ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N "" -q
fi

echo "📤 Sending SSH public key to EC2 InstanceConnect..."
aws ec2-instance-connect send-ssh-public-key \
  --instance-id "$INSTANCE_ID" \
  --instance-os-user "$USER" \
  --ssh-public-key file://"$KEY_PATH.pub" \
  --availability-zone "$AZ"

echo "🔗 Connecting to EC2 instance at $PUBLIC_IP..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "$USER@$PUBLIC_IP" <<'EOF'
  echo "✅ Connection Successful" > connection_test.txt
  cat connection_test.txt
EOF
