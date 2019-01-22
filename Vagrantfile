SERVER_COUNT = 2
CLIENT_COUNT = 1

Vagrant.configure(2) do |config|
    config.vm.box = "chavo1/xenial64base"

    1.upto(SERVER_COUNT) do |n|
      config.vm.define "consul-server0#{n}" do |server|
        server.vm.hostname = "consul-server0#{n}"
        server.vm.network "private_network", ip: "192.168.56.#{50+n}"
        server.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT}

      end
    end

    1.upto(CLIENT_COUNT) do |n|
      config.vm.define "consul-client0#{n}" do |client|
        client.vm.hostname = "consul-client0#{n}"
        client.vm.network "private_network", ip: "192.168.56.#{60+n}"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/nginx.sh"
        client.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"CLIENT_COUNT" => CLIENT_COUNT}
        
      end
    end
  end
