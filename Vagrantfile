# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "gentoo-dev"

  # install puppetmaster using puppet apply
  config.vm.define "puppet" do |puppet|

    # install and run librarian-puppet
    puppet.vm.provision :shell, :path => "shell/bootstrap.sh"

    # run puppet vagrant style
    puppet.vm.provision "puppet" do |puppet|
      puppet.module_path = "modules"
      puppet.options = "--parser future --pluginsync"
      puppet.manifest_file = "puppetmaster.pp"
    end

  end

  config.vm.define "binhost" do |binhost|
      binhost.puppet.manifest_file = "binhost.pp"
  end
end
