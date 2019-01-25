#!/usr/bin/env bash

which nginx &>/dev/null || {
    sudo apt get update -y
    sudo apt install nginx -y
    }

service nginx stop

IPs=$(hostname -I | cut -f2 -d' ')
HOST=$(hostname)


#!/usr/bin/env bash

sudo mkdir -p /vagrant/pkg

if which envconsul >/dev/null; then

echo $nginx > /var/www/html/index.nginx-debian.html

# Another examples
# envconsul -pristine -prefix nginx env | sed 's/consul-client01=//g' > /var/www/html/index.nginx-debian.html
# export `envconsul -pristine -prefix nginx env`; env
else
  
  # Updating nginx start page
set -x
rm /var/www/html/index.nginx-debian.html
sudo curl -s 127.0.0.1:8500/v1/kv/consul-client01/nginx?raw > /var/www/html/index.nginx-debian.html

set +x

fi

service nginx start

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


