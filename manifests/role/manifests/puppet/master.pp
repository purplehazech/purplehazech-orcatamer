class role::puppet::master {
  include ::profile::system
  include ::profile::puppet::master

  Class['::profile::system'] ->
  Class['::profile::puppet::master']
}


