# ## Node: puppet
#
# Installs a puppetmaster with puppetdb and puppetboard.
#
node 'puppet' {
  include ::role::puppet::master
}
