
import 'default.pp'

node puppet {

  # mysql on puppetmaster (this needs to move into profile::mysql::server)
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
  }

  # inject mysql_install_db call into example42/mysql module
  exec { '/usr/bin/mysql_install_db':
    require => Package['mysql'],
    before  => Service['mysql'],
    creates => '/var/lib/mysql/mysql'
  }

}
