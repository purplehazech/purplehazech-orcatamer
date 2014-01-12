# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "gentoo-dev"

  # install and runn librarian-puppet
  config.vm.provision :shell, :path => "shell/bootstrap.sh"

  # run puppet vagrant style
  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
  end
end
