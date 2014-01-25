class role::puppet::master {
  include ::profile::system
  include ::profile::mysql::server
  include ::profile::puppet::master

  Class['::profile::system'] ->
  Class['::profile::mysql::server'] ->
  Class['::profile::puppet::master']
}

class role::binhost {
}
