#!/usr/bin/env bash

SERVER_COUNT=${SERVER_COUNT}
CONSUL=1.4.0


# Install packages

apt-get update -y
which unzip socat jq dnsutils vim curl dnsmasq &>/dev/null || {
apt-get install unzip socat jq dnsutils vim curl dnsmasq -y 
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

# Consul DNS to be resolved as well as external

sudo echo "server=/consul/127.0.0.1#8600" > /etc/dnsmasq.d/10-consul

sudo sed -i 's/#resolv-file=/resolv\-file=\/etc\/dnsmasq.d\/external.conf/g' /etc/dnsmasq.conf

cat << EOF > /etc/dnsmasq.d/external.conf
server=8.8.8.8
EOF

sudo systemctl restart dnsmasq

killall consul

# Starting consul server

IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)


if [[ $HOST =~ consul-server* ]]; 
then

consul agent -server -ui -bind 0.0.0.0 -advertise $IPs -client 0.0.0.0 -data-dir=/tmp/consul \
-bootstrap-expect=$SERVER_COUNT -retry-join=192.168.56.52 \
-retry-join=192.168.56.51 -retry-join=192.168.56.61 -retry-join=192.168.56.62 > /tmp/consul.log & 

sleep 5

fi

