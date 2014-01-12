# gentoo-dev

Contains my personal development setup I use for developing
gentoo related things. For now this only has 64bit support.

## install
### vagrant
I use a vagrant install from http://vagrantup.com

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

## vagrant usage

after building with veewee the following should work

``bash
vagrant box add gentoo-dev ...box
vagrant up
``

## todo
* [x] install librarian-puppet during veewee phase (see shell/bootstrap.sh)
* [x] switch logger to syslog-ng from metalog during veewee phase (see manifests/default.pp)
* [ ] vixie cron support in syslogng puppet module
* [x] local Veeveefile and templates
* [ ] find a way to force build on missing binpkg
* [ ] use these on veewee output to find unbuilt packages
``
  />>> .* (. of .) /
  /^\(=.*\)$/
  /\[ebuild.*\] \(.*\) .*$/
``
