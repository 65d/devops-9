#!/bin/bash

INSTANCE_ID="$1"

if [ -z "$INSTANCE_ID" ]; then
  echo "Usage: $0 <instance-id>"
  exit 1
fi

read -p "Are you sure you want to terminate the instance $INSTANCE_ID? (y/n): " confirm

if [ "$confirm" = "y" ]; then
  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
else
  echo "Instance termination cancelled."
fi