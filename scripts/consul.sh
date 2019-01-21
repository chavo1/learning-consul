#!/usr/bin/env bash

apt-get update -y
apt-get install unzip socat jq dnsutils -y 

SERVER_COUNT=${SERVER_COUNT}

# Install consul
which consul || {
pushd /usr/local/bin/
wget https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip
unzip consul_1.4.0_linux_amd64.zip
rm -fr consul_1.4.0_linux_amd64.zip
popd
}

# Starting consul
killall consul
IPs=$(hostname -I | cut -f2 -d' ')


set +x

consul agent -server -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul -bootstrap-expect=$SERVER_COUNT -retry-join=192.168.56.52 -retry-join=192.168.56.51 > /tmp/consul.log & 
        
sleep 5
set +x
