#!/usr/bin/env bash

SERVER_COUNT=${SERVER_COUNT}
CONSUL_VERSION=${CONSUL_VERSION}


# Install packages

apt-get update -y
which unzip socat jq dnsutils vim curl &>/dev/null || {
apt-get install unzip socat jq dnsutils vim curl -y 
}

# Install consul

sudo mkdir -p /vagrant/pkg

# consul file exist.
CHECKFILE="/vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip"

if [ -f "$CHECKFILE" ]; 
then
pushd /usr/local/bin/
cp /vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip /usr/local/bin/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chmod +x consul
popd
echo 'File is there, all good!'
else

# consul file not exist
echo 'File is not there Downloading...'
which consul || {
pushd /usr/local/bin/
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
cp consul_${CONSUL_VERSION}_linux_amd64.zip /vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chmod +x consul
popd
}
fi

killall consul

# Starting consul servers

IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)


if [[ $HOST =~ consul-server* ]]; 
then

consul agent -server -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul \
-bootstrap-expect=$SERVER_COUNT -retry-join=192.168.56.52 \
-retry-join=192.168.56.51 -retry-join=192.168.56.61 -retry-join=192.168.56.62 > /tmp/consul.log & 

sleep 5

fi

