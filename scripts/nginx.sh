#!/usr/bin/env bash

which nginx &>/dev/null || {
    sudo apt get update -y
    sudo apt install nginx -y
    }

IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)


sudo mkdir -p /etc/consul.d

sudo cat <<EOF > /etc/consul.d/web.json
{"service": {"name": "web", "tags": ["$HOST"], "port": 80,
"check": {"args": ["curl", "127.0.0.1"], "interval": "3s"}}}
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

# Starting consul clients

killall consul

consul agent -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul \
 -enable-script-checks=true -config-dir=/etc/consul.d -retry-join=192.168.56.52 \
 -retry-join=192.168.56.51 -retry-join=192.168.56.61 -retry-join=192.168.56.62 > /tmp/consul.log & 

sleep 5

consul reload

consul members
