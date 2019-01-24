#!/usr/bin/env bash

SERVER_COUNT=${SERVER_COUNT}
CONSUL_VERSION=${CONSUL_VERSION}

# Install packages

which unzip socat jq dig route vim curl &>/dev/null || {
    apt-get update -y
    apt-get install unzip socat net-tools jq dnsutils vim curl -y 
}

#####################
# Installing consul #
#####################
sudo mkdir -p /vagrant/pkg

which consul || {
    # consul file exist.
    CHECKFILE="/vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip"
    if [ ! -f "$CHECKFILE" ]; then
        pushd /vagrant/pkg
        wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
        popd
 
    fi
    
    pushd /usr/local/bin/
    unzip /vagrant/pkg/consul_${CONSUL_VERSION}_linux_amd64.zip 
    sudo chmod +x consul
    popd
}

killall consul

sudo mkdir -p /etc/consul.d /vagrant/consul_logs

###########################
# Starting consul servers #
###########################
IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)

if [[ $HOST =~ consul-server* ]]; then

    consul agent -server -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul \
-bootstrap-expect=$SERVER_COUNT -retry-join=192.168.56.52 \
-retry-join=192.168.56.51 > /vagrant/consul_logs/$HOST.log & 

else
    consul agent -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul \
 -enable-script-checks=true -config-dir=/etc/consul.d -retry-join=192.168.56.52 \
 -retry-join=192.168.56.51 > /vagrant/consul_logs/$HOST.log & 

fi

sleep 5

consul members

