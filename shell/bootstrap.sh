#!/bin/sh

# run librarian-puppet
cd /vagrant
echo 'librarian-puppet install --clean'
librarian-puppet install --clean

# run eix-update so puppet finds packages
echo 'eix-update'
eix-update
