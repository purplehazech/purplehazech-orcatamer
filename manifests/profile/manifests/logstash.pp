# ## Class: profile::logstash
#
# Runbook for installing logstash.
#
# ### Dependencies
# * ::profile::laymanadd
#
 class profile::logstash {

  # ### Layman Overlays
  # * chaos overlay from github has a logstash ebuild
  exec { 'layman-add-chaos-overlay':
    command => '/usr/bin/layman-add chaos git git://github.com/travisghansen/chaos.git',
    creates => '/var/lib/layman/chaos',
  } ~>
  # remember to call eix-update after using layman-add
  exec { 'eix-update-for-chaos-overlay':
    command     => '/usr/bin/eix-update',
    refreshonly => true,
  } ->
  # ### Packages
  package_keywords {
    # set ~amd64 keywording for some dependency form portage tree first
    [
    'dev-python/urllib3',
    'dev-python/pyes',
  ]:
    ensure   => present,
    keywords => [
      '~amd64',
    ],
  } ->
  package {
    # * logstash from chaos overlay
    'sys-apps/logstash':
      ensure => installed,
  } ->
  # ### Configuration
  file {
    # Set up logstash configuration for syslog-ng integraton.
    '/etc/logstash/conf.d/syslog.conf':
    ensure => file,
    # For the moment this is set up to use a file called .erb without running
    # it through erb since i was lazy.
    # @todo Fix this as soon as we are running in a proper module context.
    source => '/vagrant/manifests/profile/templates/logstash/syslog.conf.erb',
    notify => Service['logstash'],
  }
  augeas {
    # Enable WEB_START in distro base logstash config
    'logstash-confd':
      context => '/files/etc/conf.d/logstash',
      lens    => 'Shellvars.lns',
      incl    => '/etc/conf.d/logstash',
      changes => [
        'set WEB_START true',
      ],
  } ~>
  service {
    # Start logstash service properly
    'logstash':
      ensure => running,
      enable => true,
  } ~>
  exec {
    # @todo remove this since we switched to udp
    'restart-syslog-ng-after-logstash':
      command     => '/etc/init.d/syslog-ng restart',
      refreshonly => true,
  }
}
