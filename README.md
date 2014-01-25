# gentoo-dev

Contains my personal development setup I use for developing
gentoo related things. For now this only has 64bit support.

## lifecycle of a box

* box gets built from stage3 with veewee using binary packages
* box gets exported as vagrant box
* box gets imported in vagrant
* box is used to provision a complete environment using vagrant
* provisioned environment is used to build binary packages and stage3 boxes

## install

You need to install some prerequisite tools to start using this.

### vagrant
I use a vagrant install from http://vagrantup.com

### veewee
At the moment veewee is run on the developer system and needs to
be installed. For now it is recommended to use rvm bundle and
install veewee locally to the project.

``bash
# install veewee
rvm 2.1.0 exec bundle install
# call veewee like so after install (create an alias)
rvm 2.1.0 exec bundle exec veewee
``

## veewee usage

You can use veewee to build base boxes. This repo contains a
definition for a gentoo box based on the specs that most of
my machines will have.

``bash
veewee vbox build  'gentoo-dev'
veewee vbox export 'gentoo-dev'
``

## vagrant usage

After building and exporting a veewee box you can add it to
vagrant and use it to provision a puppet master.

``bash
vagrant box add gentoo-dev gentoo-dev.box
vagrant up puppet
``

If you want to install the full environment run ``vagrant up``
without a box argument to start all the configured boxes.

## cleanup

``bash
# remove virtual machine built by veewee
veewee vbox remove gentoo-dev
# remove all miachines deployed by vagrant
vagrant destroy
# remove base bo from vagrant
vagrant box remove gentoo-dev
``

## usage

You now have a fully puppetized gentoo latest box that is configured
for building binary packages. The packages built within are stored
in ``vagrant/packages`` so they stay available after the box has been
destroyed and on subsequent rebuilds.

## todo
* [x] install librarian-puppet during veewee phase (see shell/bootstrap.sh)
* [x] switch logger to syslog-ng from metalog during veewee phase (see manifests/default.pp)
* [ ] vixie cron support in syslogng puppet module
* [x] local Veeveefile and templates
* [x] inject /etc/puppet/hiera.yaml with vagrant
* [ ] find a way to force build on missing binpkg
* [ ] use these on veewee output to find unbuilt packages
``
  />>> .* (. of .) /
  /^\(=.*\)$/
  /\[ebuild.*\] \(.*\) .*$/
``
