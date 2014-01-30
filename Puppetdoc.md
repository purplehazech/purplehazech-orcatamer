

# Site: orcatamer


#
This site includes all the available nodes in a orca tamer
setup. It is used during all kinds of puppet runs along
with the modules loaded using ``librarian-puppet`` during
provisioning.


#


## Node: binhost


#
Simple node with almost nothing.


#
This proof of concept machine is here so we always have a
baseline indicator to tell if build are failing due to the
base setup or some interaction with any of the deployed
services.


#


## Node: default


#
Default node, basically just makes sure the machine ist tamed
by orca tamer. This should not get used anywhere since we don't
need any default nodes in the system. Nodes should always be
provisioned for a specific role and never directly include
a profile. This definition is here so we never lose control
of our agents.


#


## Node: logstash


#
The logstash node has an elsticsearch/logstash setup running and is
configured so to enable centralized log viewing.


#


## Node: puppet


#
A puppet master node with puppetdb and puppetboard.


#


## Class: role::infra::binhost


#
Binary package host.


#


## Class: role::logstash


#


## Class: role::puppet::master


#


#


## Class: profile::elasticsearch


#
Installs the most current ~amd64 elasticsearch package
available on portage.


#


## Class: profile::laymanadd


#
Add the ``layman-add`` tool to ease layman overlay management.


#


### layman overlays
* betagarden contains the layman-add tool
we need to sync eix after adding overlays so puppet sees them


### Packages
* layman-add script for adding layman overlays from git and elsewhere


## Class: profile::logstash


#
Runbook for installing logstash.


#


### Dependencies
* ::profile::laymanadd


#


### Layman Overlays
* chaos overlay from github has a logstash ebuild
remember to call eix-update after using layman-add


### Packages
set ~amd64 keywording for some dependency form portage tree first
* logstash from chaos overlay


### Configuration
Set up logstash configuration for syslog-ng integraton.
For the moment this is set up to use a file called .erb without running
it through erb since i was lazy.
@todo Fix this as soon as we are running in a proper module context.
Enable WEB_START in distro base logstash config
Start logstash service properly
@todo remove this since we switched to udp


## Class: profile::puppet::master


#
Contains the run book for installing a complete puppetmaster setup on
a current gentoo node. Since this run book uses some highly experimental
tooling it will not run on any platform other than gentoo anytime soon.


#
The largest problems with this run book are as follows.
* puppetdb is installed from binaries using leiningen
* puppetboard is installed using pip
* it should use postgresql as intended by puppetdb


#
The rest of the run book is ready to be installed from binaries, so
at least its got that going.


#


### PuppetDB


#### Overlays
* optiz0r overlay has with leiningen
rabe-portage-overlay has a more current puppetdb than optiz0r
always run eix-sync after using layman-add manually
@todo abstraction for layman-add as puppet-module


#### Packages


#### Configuration


### puppetboard


#### Packages
* pip is used due to puppetboard not being in portage (yet)
* nginx is used as a webserver since it is small, light and fast
* uwsgi will be used behind nginx as python thread manager


### Pip Puppetboard Install
Use python2.7 pip to ``pip install puppetboard``.
Make sure the nginx conf.d support is available.
Let external nginx module do its magic.
rewrite gentoo nginx.conf to add conf.d support using sed in a quirky
manner due to the augeas Nginxconf.lns lens not supporting nested
configs ala gentoo.
Trigger nginx restart manually afterwards since the service is managed 
by the nginx class and I can't notify => it from here due to circular
dependency issues with that.


### Nginx Configuration
Configure puppetboard as an upstream resource using nginx module.
Make sure the wwwroot exists and is readable.
add puppetboard vhost to nginx config using a local template
made for puppetboard.
@todo Use the erb file as template after switch to being module.


### Puppetboard Configuration
Add ``puppetboard`` system group.
Add ``puppetboard`` system user.
Create logdir with ``puppetboard`` permissions.
Set basic uswgi options injected via UWSGI_EXTRA_OPTIONS in conf.d.
Create one-liner ``uwsgi.py`` python uwsgi runtime as per
puppetboard documentation.
Create ``uwsgi.puppetboard`` symlink in gentoo uswgi config fashion.
Start and enabel ``uswgi.puppetboard`` service.


### Puppet Master install
  #} ->
  #service { 'puppet':
 ensure => running,
 enable => true,
these must exists even on an empty repo
after running this the first time it
should get populated by binaries that
make subsequentive runs much faster
manage /etc/portage/make.conf
enable local overlay (this is a dev box after all)
activate binary package building
use binary packages when available
so we don't need bindist due to openssl
these are currently setup for virtualbox support
install most portage tools
bump eix due to bugs with --format '<bestversion:LASTVERSION>' in 0.29.0
install ccache since these are dev/build boxes
remove any other sysloggers (from veewee or stage3)
setup augeas 1.x
some flags that make more sense here than in puppet or elasticsearch
in the long run they will move though
