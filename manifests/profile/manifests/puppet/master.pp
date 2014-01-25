# = Class: profile::puppet::master
#
#
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
        'set manifest /vagrant/manifests/site.pp',
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
        'set autosign true',
      ];
    'puppet agent config':
      context => '/files/etc/puppet/puppet.conf/agent',
      changes => [
        "set certname ${::fqdn}",
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
