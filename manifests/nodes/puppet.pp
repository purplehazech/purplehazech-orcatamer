# ## Node: puppet
#
# A puppet master node with puppetdb and puppetboard.
#
node 'puppet' {
  include ::role::puppet::master
}
