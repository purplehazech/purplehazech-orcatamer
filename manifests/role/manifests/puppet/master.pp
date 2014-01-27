# # Class: role::puppet::master
#
#
class role::puppet::master {
  include ::profile::system
  include ::profile::laymanadd
  include ::profile::puppet::master

  Class['::profile::system'] ->
  Class['::profile::laymanadd'] ->
  Class['::profile::puppet::master']
}


