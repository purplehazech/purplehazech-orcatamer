# everything in here should be in a module called something like stoneycloud-profile

class profile::system {

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
    # so we don't need bindist due to openssl
    'curl_ssl':
      ensure  => present,
      content => 'gnutls';
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
    # bump eix due to bugs with --format '<bestversion:LASTVERSION>' in 0.29.0
    eix_ensure           => '0.30.0',
    eix_keywords         => ['~amd64'],
    layman_ensure        => present,
    webapp_config_ensure => present,
    eselect_ensure       => present,
    portage_utils_ensure => present
  } ->
  # install ccache since these are dev/build boxes
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
  }
}

class profile::puppet::master {

  $optiz0r_overlay = 'git://github.com/optiz0r/gentoo-overlay.git'
  $rabe_overlay = 'git://github.com/purplehazech/rabe-portage-overlay.git'

  # puppetdb
  layman {
    # overlay containing layman-add tool
    'betagarden':
      ensure => present,
  } ->
  package_keywords { 'app-portage/layman-add':
    ensure   => 'present',
    keywords => '~amd64',
  }
  package { 'app-portage/layman-add':
    ensure => present,
  } ->
  exec {
    # overlay with leiningen
    'layman-add-optiz0r-overlay':
      command => "/usr/bin/layman-add optiz0r git ${optiz0r_overlay}",
      creates => '/var/lib/layman/optiz0r';
    # overlay with more current puppetdb than optiz0r
    'layman-add-rabe-overlay':
      command => "/usr/bin/layman-add rabe git ${rabe_overlay}",
      creates => '/var/lib/layman/rabe',
  } ->
  layman {
    'optiz0r':
      ensure => present;
    'rabe':
      ensure => present;
  } ->
  package_keywords { [
    'app-admin/puppetdb',
    'dev-lang/leiningen',
  ]:
    ensure   => present,
    keywords => '~amd64',
  } ->
  package_use { 'dev-java/icedtea-bin':
    ensure => present,
    use    => '-X',
  } ->
  package { [
    'closure',
    'app-admin/puppetdb'
  ]:
    ensure => present,
  } ->
  service { 'puppetdb':
    ensure => running,
    enable => true
  }

  # puppetmaster
  package_use { 'app-admin/puppet':
    ensure => present,
    use    => [
      'augeas',
      'diff',
      'doc',
      'shadow',
      'vim-syntax'
    ]
  } ->
  package { 'app-admin/puppet':
    ensure => installed,
  } ->
  augeas {
    'puppet main setup':
      context => '/files/etc/puppet/puppet.conf/main',
      changes => [
        'set modulepath /vagrant/modules',
        'set manifestdir /vagrant/manifest',
        'set manifest /vagrant/manifest/all.pp',
        'set pluginsync true',
        'set parser future',
     ];
    'puppet master setup':
      context => '/files/etc/puppet/puppet.conf/master',
      changes => [
        "set server ${::fqdn}",
        'set reports store',
        'set storeconfigs true',
        'set dbadapter mysql',
        'set dbuser puppet',
        'set dbpassword vagrant',
        'set dbserver localhost'
      ];
  } ->
  service { 'puppetmaster':
    ensure => running,
    enable => true,
  #} ->
  #service { 'puppet':
  #  ensure => running,
  #  enable => true,
  }
}

class profile::mysql::server {
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

class profile::optroot {
  file { '/opt/php-5.4-lighttpd':
    ensure => directory,
  }
}

class profile::build::lsb {
  package { 'sys-apps/lsb-release':
    ensure => present,
  } ->
  package_kewords { [
    'dev-util/rpmdevtools',
    'dev-util/checkbashisms',
  ]:
    ensure   => present,
    keywords => '~amd64',
  } ->
  package_use { 'app-arch/rpm':
    ensure => present,
    use    => [
      'python',
    ]
  } ->
  package { 'dev-util/rpmdevtools':
    ensure => present,
  }
}
