# orca-tamer

The orca tamer is a gentoo penguin from the clan of the
warrior penguins. Even in the eye of danger he persists
until finally forging an allegiance with local researchers
on the lookout thus saving himself from the maddingly vast
hordes of hungry orcas.

When the orca tamer got into GNU/Linux he decided that he
needed a stable(ish) base setup based upon the foundations
of Gentoo Linux but with added binary packaging and tools
for automating all the things.

At the moment orca tamer can start to get you developing
puppet manifests for gentoo in a short time. For now this
only has 64bit support.

Some binary packages are already available for the system.
Please consider those proof of concept only, I will stop
offering those until orca tamer has stabilzed soon(ish).

This needs heaps of work, please create issues and send
pull requests. You can also use the github comment feature
if you don't grok a commit of mine, I'll be happy to clarify
and document where there are issues.

## Lifecycle of a Box

* box gets built from stage3 with veewee using binary packages
* box gets exported as vagrant box
* box gets imported in vagrant
* box is used to provision a complete environment using vagrant
* provisioned environment is used to build binary packages and stage3 boxes

## Available Boxes

| Machine      | IP (vbox internal network) | exposed ports                              | description 
| ------------ | -------------------------- | ------------------------------------------ | -----------
| puppet       | 10.30.0.10                 | 8080 -> puppetboard                        | Primary puppet master. Must always run first since it is used to bootstrap the remaining machines.
| binhost      | 10.30.0.20                 |                                            | Bare Linux install with the ``::profile::system`` profile.
| logstash     | 10.30.0.30                 | 8081 -> logstash, 9200 -> elasticsearch    | Central logfile aggregation and parsing, made awesome with logstash and syslog-ng.

## Quickstart

Given you already have a working vagrant/virtualbox install. This should work.

````bash
git clone https://github.com/purplehazech/purplehazech-orcatamer.git
cd purplehazech-orcatamer
vagrant up puppet
````

You now have a running puppet master instance with puppetdb and puppetboard set
to go. The puppetboard instance should be available at http://localhost:8080 at
this point.

You can now start your first puppet agent based machine.

````bash
vagrant up binhost
````

At some point vagrant will say ``Running provisioner: puppet_server...`` and you
get to wait until puppet has run on the machine so you can inspect the results
in puppetboard.

Binhost ist an empty machine that gets installed with binary packages.

## Install

You need to install some prerequisite tools to start use

### virtualbox
For the moment this runs on virtualbox. I plan on adding support
for other clouds later.

### vagrant
I use a vagrant install from http://vagrantup.com

### veewee
Veewee is used to build from stage3/portage-snapshot to a vagrant
box.

````bash
# install veewee
rvm 2.1.0 exec bundle install
# call veewee like so after install (create an alias)
rvm 2.1.0 exec bundle exec veewee
````

## vagrant usage

After building and exporting a veewee box you can add it to
vagrant and use it to provision a puppet master.

````bash
vagrant box add gentoo-dev gentoo-dev.box
vagrant up puppet
````

If you want to install the full environment run ``vagrant up``
without a box argument to start all the configured boxes.

## veewee usage

You can use veewee to build base boxes. This repo contains a
definition for a gentoo box based on the specs that most of
my machines will have.

````bash
veewee vbox build  'gentoo-dev'
veewee vbox export 'gentoo-dev'
````

## cleanup

````bash
# remove virtual machine built by veewee
veewee vbox remove gentoo-dev
# remove all miachines deployed by vagrant
vagrant destroy
# remove base bo from vagrant
vagrant box remove gentoo-dev
````

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
* [ ] refactor docs to make veewee less important
* [ ] split ``manifests/{profile,role}`` into their own modules
* [ ] find a way to force build on missing binpkg
* [ ] create veewee machine
* [ ] manage /etc/hosts and switch to hostnames where ips are in use (only in ``::profile`` afaik)
* [ ] refactor veewee build to install puppet right away and only use puppet thereafter
* [ ] use these (with logstash) on veewee output to find unbuilt packages
``
  />>> .* (. of .) /
  /^\(=.*\)$/
  /\[ebuild.*\] \(.*\) .*$/
``
