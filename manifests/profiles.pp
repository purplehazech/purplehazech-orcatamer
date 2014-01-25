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
      content => 'version: 2',
      mode    => '0744',
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
    'portage_binhost':
      ensure  => present,
      content => [
        'http://bindist.hairmare.ch/gentoo-dev/portage/packages/',
      ];
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
  exec { 'sync-layman':
    command     => '/usr/bin/layman -S',
    refreshonly => true,
    subscribe   => Package['app-portage/layman'],
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

  # setup augeas 1.x
  package_keywords { 'app-admin/augeas':
    ensure   => present,
    keywords => [
      '~amd64',
    ],
    version  => '1.1.0'
  } ~>
  package { 'app-admin/augeas':
    ensure => installed,
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
  exec { 'sync-eix-for-betagarden':
    command     => '/usr/bin/eix-update',
    refreshonly => true,
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
  } ~>
  exec { 'sync-eix-for-puppetdb':
    command     => '/usr/bin/eix-update',
    refreshonly => true,
  } ->
  package_use {
    'x11-libs/cairo':
      ensure => present,
      use    => [
        'X'
      ];
    'app-text/ghostscript-gpl':
      ensure => present,
      use    => [
        'cups',
      ];
  } ->
  package_keywords { [
    'app-admin/puppetdb',
    'dev-lang/leiningen',
  ]:
    ensure   => present,
    keywords => '~amd64',
  } ->
  package { [
    'dev-lang/clojure',
    'app-admin/puppetdb'
  ]:
    ensure => present,
  } ->
  file { [
    '/var/run/puppetdb',
    '/var/lib/puppetdb/state',
    '/var/lib/puppetdb/db',
    '/var/lib/puppetdb/config',
    '/var/lib/puppetdb/mq',
  ]:
    ensure => directory,
    owner  => 'puppetdb',
  } ->
  file { '/etc/puppetdb/conf.d':
    ensure => directory,
    mode   => '0755',
  } ->
  file { '/etc/puppetdb/log4j.properties':
    ensure => file,
    mode   => '0644',
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
        'set manifestdir /vagrant/manifests',
        'set manifest /vagrant/manifests/all.pp',
        'set pluginsync true',
        'set parser future',
      ];
    'puppet master setup':
      context => '/files/etc/puppet/puppet.conf/master',
      changes => [
        "set server ${::fqdn}",
        'set reports store,puppetdb',
        'set storeconfigs true',
        'set storeconfigs_backend puppetdb',
      ];
    'puppetdb puppet config':
      context => '/files/etc/puppet/puppetdb.conf/main',
      lens    => 'Puppet.lns',
      incl    => '/etc/puppet/puppetdb.conf',
      changes => [
        "set server ${::fqdn}",
      ];
    'puppetdb routes config':
      context => '/files/etc/puppet/routes.yaml/master/facts',
      changes => [
        'set terminus puppetdb',
        'set cache yaml',
      ];
    'puppetdb jetty config':
      context => '/files/etc/puppetdb/conf.d/jetty.ini/jetty',
      lens    => 'Puppet.lns',
      incl    => '/etc/puppetdb/conf.d/jetty.ini',
      changes => [
        'set host 0.0.0.0',
      ],
      require => Package['app-admin/puppetdb'];
  } ~>
  service { 'puppetmaster':
    ensure => running,
    enable => true,
  }
  Service['puppetmaster'] -> Exec['puppetdb-ssl-setup']

  exec { 'run-puppet-agent-once':
    command     => '/usr/bin/puppet agent --test --noop',
    refreshonly => true
  } ->
  exec { 'puppetdb-ssl-setup':
    command => '/usr/sbin/puppetdb-ssl-setup',
    creates => [
      '/etc/puppetdb/ssl/ca.pem',
      '/etc/puppetdb/ssl/private.pem',
      '/etc/puppetdb/ssl/public.pem',
    ],
    notify  => Service['puppetdb'],
  #} ->
  #service { 'puppet':
  #  ensure => running,
  #  enable => true,
  }
}
