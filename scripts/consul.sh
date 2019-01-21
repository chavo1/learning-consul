#!/usr/bin/env bash

apt-get update -y
apt-get install unzip socat jq dnsutils curl -y 

SERVER_COUNT=${SERVER_COUNT}

# Install consul
which consul || {
pushd /usr/local/bin/
wget https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip
unzip consul_1.4.0_linux_amd64.zip
rm -fr consul_1.4.0_linux_amd64.zip
popd
}

cd /vagrant
# Starting consul
killall consul
IPs=$(hostname -I | cut -f2 -d' ')

set +x

cd /vagrant
consul agent -server -ui -bootstrap-expect=$SERVER_COUNT \
    -data-dir=/tmp/consul -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 \
    -enable-script-checks=true -config-dir=consul.d -retry-join=192.168.56.52 -retry-join=192.168.56.51> /tmp/consul.log &
sleep 5
set +x

consul reload

consul members
