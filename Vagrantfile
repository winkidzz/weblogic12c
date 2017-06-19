# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "hashicorp/precise64"
  config.vm.box_download_insecure = true
  config.vm.provision :shell, path: "bootstrap.sh"

  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "chef/cookbooks"
    chef.data_bags_path = "chef/data_bags"
    chef.nodes_path = "chef/nodes"
    chef.roles_path = "chef/roles"
    chef.environments_path = "chef/environments"
    
    chef.add_recipe "fmw_jdk::install"
    chef.add_recipe "fmw_jdk::rng_service"
    chef.add_recipe "fmw_wls::setup"
    chef.add_recipe "fmw_wls::install"
    chef.add_recipe "fmw_domain::domain"
    chef.add_recipe "fmw_domain::nodemanager"
    chef.add_recipe "fmw_domain::adminserver"

    chef.json = {
     "fmw_jdk" => {
          "source_file" => "/guest_host/software/jdk-8u40-linux-x64.tar.gz"
      },
      "fmw" => {
          "java_home_dir" => "/usr/java/jdk1.8.0_40",
	  "middleware_home_dir": "/opt/oracle/middleware_1213",
	  "weblogic_home_dir":   "/opt/oracle/middleware_1213/wlserver",
	  "version":             "12.2.1"
      },
      "fmw_wls": {
	  "source_file":         "/guest_host/software/fmw_12.2.1.0.0_wls.jar"
      },
      "fmw_domain": {
          "databag_key":                "DEV_WLS1",
	  "domains_dir":                "/opt/oracle/middleware_1213/user_projects/domains",
          "nodemanager_listen_address": "10.0.2.15"
   }
    }
  end

  config.vm.network :forwarded_port, guest: 7001, host: 4568, auto_correct: true
	

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/guest_host"
  #config.vm.synced_folder "../../Oracle/Middleware_122100/user_projects/domains/flex/autodeploy", "/opt/oracle/middleware_1213/user_projects/domains/base/autodeploy"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
   config.vm.provider "virtualbox" do |vb|
   # Display the VirtualBox GUI when booting the machine
    #vb.gui = true
  
     # Customize the amount of memory on the VM:
     vb.memory = "1024"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://10.0.2.2:3128"
    config.proxy.https    = "http://10.0.2.2:3128"
    config.proxy.no_proxy = "localhost,127.0.0.*,10.*,192.168.*,172.*,*.pxlabus.com"
  end
end
