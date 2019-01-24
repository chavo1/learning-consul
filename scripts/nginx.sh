#!/usr/bin/env bash

which nginx &>/dev/null || {
    sudo apt get update -y
    sudo apt install nginx -y
    }

service nginx stop

IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)

# Updating nginx start page
set -x
rm /var/www/html/index.nginx-debian.html
sudo curl -s 127.0.0.1:8500/v1/kv/$HOST?raw >> /var/www/html/index.nginx-debian.html
service nginx start
set +x

sudo mkdir -p /etc/consul.d

#####################
# Register services #
#####################
sudo cat <<EOF > /etc/consul.d/web.json
{
  "service": {
    "name": "web",
    "tags": ["$HOST"],
    "port": 80,
  "check": {
    "args": ["curl", "127.0.0.1"],
    "interval": "3s"
    }
  }
}
EOF

sudo cat <<EOF > /etc/consul.d/http.json
{
  "check": {
    "id": "http",
    "name": "http TCP on port 80",
    "tcp": "127.0.0.1:80",
    "interval": "10s",
    "timeout": "1s"
  }
}
EOF

consul reload

consul members


