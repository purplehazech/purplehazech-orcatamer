node default {

  # these must exists even on an empty repo
  # after running this the first time it
  # should get populated by binaries that
  # make subsequentive runs much faster
  file {
    '/vagrant/portage':
      ensure => directory;
    '/vagrant/portage/packages':
      ensure => directory;
    '/etc/puppet/hiera.yaml':
      ensure  => file,
      content => 'version: 2'
  } ->
  # manage /etc/portage/make.conf
  portage::makeconf {
    'portdir_overlay':
      ensure  => present,
      # enable local overlay (this is a dev box after all)
      content => '/usr/local/portage';
    'source /usr/local/portage/make.conf':
      ensure => present;
    'features':
      ensure  => present,
      content => [
        'sandbox',
        'parallel-fetch',
        # activate binary package building
        'buildpkg',
        'buildsyspkg',
        # use binary packages when available
        'getbinpkg',
      ];
    'use':
      ensure  => present,
      content => [
        'nls',
        'cjk',
        'unicode'
      ];
    'pkgdir':
      ensure  => present,
      content => '/vagrant/portage/packages';
    'python_targets':
      ensure  => present,
      content => [
        'python2_7',
        'python3_2',
        'python3_3',
      ];
    'use_python':
      ensure  => present,
      content => [
        '3.2',
        '2.7',
      ];
    'ruby_targets':
      ensure  => present,
      content => [
        'ruby18',
        'ruby19',
        'ruby20',
      ];
    'linguas':
      ensure  => present,
      content => [
        'en',
      ];
    # these are currently setup for virtualbox support
    'input_devices':
      ensure  => present,
      content => [
        'evdev',
      ];
    'video_cards':
      ensure  => present,
      content => [
        'virtualbox',
      ];
  } -> Class['ccache']

  # install most portage tools
  class { 'portage':
    eix_ensure           => present,
    layman_ensure        => present,
    webapp_config_ensure => present,
    eselect_ensure       => present,
    portage_utils_ensure => present
  } ->
  # install ccache since this is a dev/build box
  class { 'ccache':
  } ->
  class { 'syslogng':
    logpaths      => {
      'syslog-ng' => {},
      'sshd'      => {},
      'sudo'      => {},
    },
  } ->
  # remove any other sysloggers (from veewee or stage3)
  service { [ 'metalog', 'rsyslog' ]:
    ensure => stopped,
  } ->
  package { [ 'metalog', 'rsyslog' ]:
    ensure => absent,
  } ->
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
  } ->
  # install a zabbix server
  class { 'zabbix::server':
    ensure      => present,
    db_user     => 'zabbix',
    db_password => 'zabbix',
    db_server   => 'localhost',
  }

  # inject mysql_install_db call into example42/mysql module
  exec { '/usr/bin/mysql_install_db':
    require => Package['mysql'],
    before  => Service['mysql'],
    creates => '/var/lib/mysql/mysql'
  }

}
