#!/bin/sh

# install librarian-puppet if none exists
# @todo my boxes should already contain librarian in the future
if [ ! -x /usr/local/bin/librarian-puppet ]; then
    gem install librarian-puppet
fi

# more puppet dependencies not met by the box
# @todo also upstream these into veewee
if [ ! -x /usr/bin/eix ]; then
    emerge app-portage/eix -1
fi

# run librarian-puppet
cd /vagrant
echo 'librarian-puppet install --clean'
librarian-puppet install --clean
echo 'librarian-puppet update'
librarian-puppet update

# run eix-update so puppet finds packages
echo 'eix-update'
eix-update
