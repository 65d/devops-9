#!/bin/bash

IMAGE_ID="ami-053b0d53c279acc90"
INSTANCE_TYPE="t2.micro"
KEY_NAME=""
SECURITY_GROUP_ID=""
SUBNET_ID=""
TAG_NAME="$1"
USER_DATA_FILE="user_data.sh"
LOCAL_PORT=5566
REMOTE_PORT=2375

if [ -z "$TAG_NAME" ]; then
    echo "Usage: $0 <tag-name>"
    exit 1
fi

echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-id $SUBNET_ID \
    --user-data file://$USER_DATA_FILE \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --query "Instances[0].InstanceId" \
    --output text)

echo "Instance ID: $INSTANCE_ID"

echo "Waiting for instance to be ready..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
sleep 20

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "Public IP: $PUBLIC_IP"

aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-02e97f1db4c6059a4 \
    --protocol tcp \
    --port 5566 \
    --cidr 0.0.0.0/0


ssh -i "$KEY_NAME.pem" -L $LOCAL_PORT:127.0.0.1:$REMOTE_PORT -o StrictHostKeyChecking=no -N -f "ubuntu@$PUBLIC_IP"

sleep 30


docker -H localhost:$LOCAL_PORT build -t my-nginx .
docker -H localhost:$LOCAL_PORT run -d -p 80:80 --name nginx-server my-nginx

echo "http://$PUBLIC_IP"

echo "To stop the instance, press s"

while true; do
    read -n 1 -s key
    if [ "$key" = "s" ]; then
        ./terminate.sh $INSTANCE_ID
    fi
done
