#!/bin/bash
set -euo pipefail

# --- Get values from Terraform outputs safely ---
INSTANCE_ID=$(terraform output -json | jq -r .app_instance_id.value)
PUBLIC_IP=$(terraform output -json | jq -r .app_instance_public_ip.value)
AZ=$(terraform output -json | jq -r .app_instance_az.value)
USER="ubuntu"

# --- Validate required values ---
echo "📋 Terraform outputs:"
echo "INSTANCE_ID=$INSTANCE_ID"
echo "PUBLIC_IP=$PUBLIC_IP"
echo "AZ=$AZ"

if [[ -z "$INSTANCE_ID" || -z "$PUBLIC_IP" || -z "$AZ" ]]; then
  echo "❌ ERROR: Missing required Terraform outputs. Check your terraform state."
  exit 1
fi

# --- Generate a temporary key if not exists ---
KEY_PATH="$HOME/.ssh/temp-key"
if [ ! -f "$KEY_PATH" ]; then
  echo "🔑 Generating temporary SSH key..."
  ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N "" -q
fi

# --- Push public key to EC2 via Instance Connect ---
echo "📤 Sending SSH public key to EC2 InstanceConnect..."
aws ec2-instance-connect send-ssh-public-key \
  --instance-id "$INSTANCE_ID" \
  --instance-os-user "$USER" \
  --ssh-public-key file://"$KEY_PATH.pub" \
  --availability-zone "$AZ"

# --- Connect using the temporary key ---
echo "🔗 Connecting to EC2 instance at $PUBLIC_IP..."
ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" "$USER@$PUBLIC_IP" <<'EOF'
  echo "✅ Connection Successful" > connection_test.txt
  cat connection_test.txt
EOF
