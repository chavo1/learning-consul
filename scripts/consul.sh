#!/usr/bin/env bash

SERVER_COUNT=${SERVER_COUNT}
CONSUL=1.4.0


# Install packages

apt-get update -y
which unzip socat jq dnsutils vim curl &>/dev/null || {
apt-get install unzip socat jq dnsutils vim curl -y 
}

# Install consul
#
# consul file exist.
CHECKFILE="/vagrant/consul_${CONSUL}_linux_amd64.zip"

if [ -f "$CHECKFILE" ]; 
then
pushd /usr/local/bin/
cp /vagrant/consul_${CONSUL}_linux_amd64.zip /usr/local/bin/consul_${CONSUL}_linux_amd64.zip
unzip consul_${CONSUL}_linux_amd64.zip
sudo chmod +x consul
popd
echo 'File is there, all good!'
else

# consul file not exist
echo 'File is not there Downloading...'
which consul || {
pushd /usr/local/bin/
wget https://releases.hashicorp.com/consul/1.4.0/consul_${CONSUL}_linux_amd64.zip
unzip consul_${CONSUL}_linux_amd64.zip
cp consul_${CONSUL}_linux_amd64.zip /vagrant/consul_${CONSUL}_linux_amd64.zip
sudo chmod +x consul
popd
}
fi

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
