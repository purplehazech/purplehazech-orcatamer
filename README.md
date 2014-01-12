# gentoo-dev

Contains my personal development setup I use for developing
gentoo related things.

This assumes a recent gentoo vagrant box to be loaded as
``gentoo-dev``. I build my boxes locally using veewee like
so.

``bash
veewee vbox define 'gentoo-dev' 'gentoo-latest-amd64'
veewee vbox build  'gentoo-dev' --workdir=~/git.repos/veewee
veewee vbox export 'gentoo-dev'
``

## todo
* [ ] install librarian-puppet during veewee phase (see shell/bootstrap.sh)
* [ ] switch logger to syslog-ng from metalog during veewee phase (see manifests/default.pp)
* [ ] vixie cron support in syslogng puppet module
* [ ] local Veevee Veeveefile and templates
