#!/bin/bash

# Get values from Terraform outputs
INSTANCE_ID=$(terraform output -raw app_instance_id)
PUBLIC_IP=$(terraform output -raw app_instance_public_ip)
AZ=$(terraform output -raw app_instance_az)  # adjust to your instance AZ
USER="ubuntu"

# Generate a temporary key if not exists
KEY_PATH="$HOME/.ssh/temp-key"
if [ ! -f "$KEY_PATH" ]; then
  ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""
fi

# Push public key to EC2 via Instance Connect
aws ec2-instance-connect send-ssh-public-key \
  --instance-id "$INSTANCE_ID" \
  --instance-os-user "$USER" \
  --ssh-public-key file://"$KEY_PATH.pub" \
  --availability-zone "$AZ"

# Connect using the temporary key
ssh -i "$KEY_PATH" "$USER@$PUBLIC_IP"


#echo "Connecting to EC2 for repo: $REPO_NAME"
ssh -i "$KEY_PATH" "$USER@$PUBLIC_IP"