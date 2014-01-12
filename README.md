# gentoo-dev

Contains my personal development setup I use for developing
gentoo related things. For now this only has 64bit support.

## install
### vagrant
I use vagrant from http://vagrantup.com

### veewee

``bash
# install veewee
rvm 2.1.0 exec bundle install
# call veewee like so after install (create an alias)
rvm 2.1.0 exec bundle exec veewee
``

## veewee usage

``bash
veewee vbox build  'gentoo-dev' --workdir=~/git.repos/gentoo-dev
veewee vbox export 'gentoo-dev'
``


## todo
* [ ] install librarian-puppet during veewee phase (see shell/bootstrap.sh)
* [ ] switch logger to syslog-ng from metalog during veewee phase (see manifests/default.pp)
* [ ] vixie cron support in syslogng puppet module
* [ ] local Veevee Veeveefile and templates
