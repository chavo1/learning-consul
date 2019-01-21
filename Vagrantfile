SERVER_COUNT = 2


Vagrant.configure(2) do |config|
    config.vm.box = "chavo1/xenial64base"

    1.upto(SERVER_COUNT) do |n|
      config.vm.define "consul0#{n}" do |box|
        box.vm.hostname = "consul0#{n}"
        box.vm.network "private_network", ip: "192.168.56.#{50+n}"
        box.vm.network "forwarded_port", guest: 8500, host: 8500 + n
        box.vm.provision "shell",inline: "cd /vagrant ; bash scripts/consul.sh", env: {"SERVER_COUNT" => SERVER_COUNT}

      end
    end
  end
