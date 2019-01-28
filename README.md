# Consul Labs

### This repo contains a sample of Consul cluster deployment. 
#### It will spin up 6 Vagrant machines with 3 Consul servers and 3 Consul clients. 
- The last deployed client is with Forwarded DNS - Consul DNS, to be resolved in the consul domain as well as external, more information could be found [here](https://www.consul.io/docs/guides/forwarding.html). 
- On the clients will be installed [nginx](https://www.nginx.com/resources/wiki/) and the service will be registered.
- Will be created a "pkg" folder, where the specified Consul version will be downloaded for faster deployment.
- For Consul logs will be created a 'consul_logs' directory
- For testing purpose is created an 'infinite_loop.sh' script in folder 'scripts'.

#### The usage is pretty simple

- Vagrant should be [installed](https://www.vagrantup.com/)
- Git should be [installed](https://git-scm.com/)
- Since [Consul](https://www.consul.io/) require at least 3 servers in order to survive 1 server failure. Quorum requires at least (n/2)+1 members. If we need more servers, clients or a specific Consul or envconsul version - it is simple as just change the numbers in the Vagrantfile
```
SERVER_COUNT = 3
CLIENT_COUNT = 2
CONSUL_VERSION = '1.4.0'
ENVCONSUL_VERSION = '0.7.3'
CONSUL_TEMPLATE_VERSION = '0.19.5'
```
#### Additionally there is 3 way to populate the [NGINX](https://www.nginx.com/resources/wiki/) Welcome page:

- With [envconsul](https://github.com/hashicorp/envconsul) - Just comment 'nginx.sh' and 'consul-template.sh' under the Client section.
```
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul-template.sh", env: {"CONSUL_TEMPLATE_VERSION" => CONSUL_TEMPLATE_VERSION}
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/nginx.sh"
```
- With [consul-template](https://github.com/hashicorp/consul-template) - Just comment 'envconsul.sh' and 'call_nginx.sh' under the Client section.
```
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/envconsul.sh", env: {"ENVCONSUL_VERSION" => ENVCONSUL_VERSION}
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/call_nginx.sh"
```
- With [API](https://www.consul.io/api/kv.html) - Just comment 'consul-template.sh', 'envconsul.sh' and 'call_nginx.sh' under the Client section.
```
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul-template.sh", env: {"CONSUL_TEMPLATE_VERSION" => CONSUL_TEMPLATE_VERSION}
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/envconsul.sh", env: {"ENVCONSUL_VERSION" => ENVCONSUL_VERSION}
#client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/call_nginx.sh"
 ```

### Now we are ready to start, just follow the steps:

- Clone the repo
```
git clone https://github.com/chavo1/learning-consul.git
cd learning-consul
```
- Start the lab
```
vagrant up
```
#### Check if Consul UI is available on the following addresses:
- Servers: http://192.168.56.51:8500 etc.
- Clients: http://192.168.56.61:8500 etc.
- Client with forwarded DNS: http://192.168.56.70:8500

#### Then you can start the 'infinite_loop.sh' from consul-dns manually - it will start a curl to web.service.consul and must be stopped manually.
```
vagrant ssh consul-dns
sudo su -
/vagrant/scripts/infinite_loop.sh
```
- in order to check the Consul load balancing open the log file:
```
tail -f /vagrant/consul_logs/loop.log
```

