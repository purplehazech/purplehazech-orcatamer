# -*- mode: ruby -*-
# vi: set ft=ruby :
#                                      _                                  
#                                     ( )_                                
#              _    _ __   ___    _ _ | ,_)   _ _   ___ ___     __   _ __ 
#            /'_`\ ( '__)/'___) /'_` )| |   /'_` )/' _ ` _ `\ /'__`\( '__)
#           ( (_) )| |  ( (___ ( (_| || |_ ( (_| || ( ) ( ) |(  ___/| |   
#           `\___/'(_)  `\____)`\__,_)`\__)`\__,_)(_) (_) (_)`\____)(_)   
#
# ======================================================================================
#
#                 MODERN PUPPET INFRASTRUCTURE ON GENTOO WITH STYLE
#
# ======================================================================================
#

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# global puppet args
PUPPET_EXTRA_OPTIONS="--parser future --pluginsync"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "orcatamer"
  config.vm.box_url = "http://bindist.hairmare.ch/gentoo-dev/gentoo-dev.box"

  # install puppetmaster using puppet apply
  config.vm.define "puppet" do |box|

    box.vm.hostname = "puppet.vagrant.local"

    # install and run librarian-puppet
    box.vm.provision :shell, :path => "shell/bootstrap.sh"

    # run puppet vagrant style
    box.vm.provision "puppet" do |puppet|
      puppet.module_path = "modules"
      puppet.options = PUPPET_EXTRA_OPTIONS
      puppet.manifest_file = "site.pp"
    end

    # run puppet in agent mode to finalize install by reporting to puppetdb
    box.vm.provision "puppet_server" do |puppet|
      puppet.options = PUPPET_EXTRA_OPTIONS
    end

    box.vm.network "private_network", ip: "10.30.0.10", virtualbox__intnet: "vagrant.local"
    box.vm.network "forwarded_port", guest: 80, host: 8080
  end

  # basic featureless binary system
  config.vm.define "binhost" do |box|
      box.vm.hostname = "binhost.vagrant.local"

      box.vm.provision :shell, :path => "shell/puppethost.sh"
      box.vm.provision "puppet_server" do |puppet|
      	puppet.options = PUPPET_EXTRA_OPTIONS
      end

      box.vm.network "private_network", ip: "10.30.0.20", virtualbox__intnet: "vagrant.local"
  end

  # logstash machine
  config.vm.define "logstash" do |box|
      box.vm.hostname = "logstash.vagrant.local"

      box.vm.provision :shell, :path => "shell/puppethost.sh"
      box.vm.provision "puppet_server" do |puppet|
      	puppet.options = PUPPET_EXTRA_OPTIONS
      end

      box.vm.network "private_network", ip: "10.30.0.30", virtualbox__intnet: "vagrant.local"
      box.vm.network "forwarded_port", guest: 9292, host: 8081
      box.vm.network "forwarded_port", guest: 9200, host: 9200
  end
end
