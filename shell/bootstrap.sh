#!/bin/sh

# run librarian-puppet
cd /vagrant
echo 'librarian-puppet install --clean'
librarian-puppet install --clean
echo 'librarian-puppet update'
librarian-puppet update

# run eix-update so puppet finds packages
echo 'eix-update'
eix-update
