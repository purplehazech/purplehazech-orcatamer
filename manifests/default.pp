node default {
  include ::profile::system

  package_use { 'virtual/mysql':
    ensure => present,
    use    => [
      '-minimal'
    ]
  } ->
  # configure mysql (to be made optional later)
  class { 'mysql':
    root_password => 'auto',
    package       => 'virtual/mysql',
    service       => 'mysql',
  #} ->
  # install a zabbix agent (also pulls server install?)
  #class { 'zabbix::agent':
  #  server  => 'localhost'
  #} ->
  # install a zabbix server
  #class { 'zabbix::server':
  #  db_user     => 'zabbix',
  #  db_password => 'zabbix',
  #  db_server   => 'localhost',
  }

  # inject mysql_install_db call into example42/mysql module
  exec { '/usr/bin/mysql_install_db':
    require => Package['mysql'],
    before  => Service['mysql'],
    creates => '/var/lib/mysql/mysql'
  }

}
