#!/bin/bash

apt-get update -y
apt-get install -y docker.io net-tools

cat <<EOF > /etc/docker/daemon.json
{
  "hosts": ["tcp://127.0.0.1:2375", "unix:///var/run/docker.sock"]
}
EOF

sed -i 's|-H fd://||g' /lib/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker

usermod -aG docker ubuntu