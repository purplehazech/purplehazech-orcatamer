node default {

  # these must exists even on an empty repo
  # after running this the first time it
  # should get populated by binaries that
  # make subsequentive runs much faster
  file {
    '/vagrant/portage':
      ensure => directory;
    '/vagrant/portage/packages':
      ensure => directory,
  } ->
  portage::makeconf {
    'portdir_overlay':
      ensure  => present,
      # enable local overlay (this is a dev box after all)
      content => '/usr/local/portage';
    'features':
      ensure  => present,
      content => [
        'sandbox',
        # activate binary package building
        'buildpkg',
        'buildsyspkg',
        # use binary packages when available
        'getbinpkg',
      ];
    'pkgdir':
      ensure  => present,
      content => '/vagrant/portage/packages',
  } ->
  # install layman since we'll use him anyway
  package { 'layman':
    ensure   => present,
    provider => 'portage',
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
  # @todo switch veewee box to syslog-ng
  service { [ 'metalog', 'rsyslog' ]:
    ensure => stopped,
  } ->
  package { [ 'metalog', 'rsyslog' ]:
    ensure => absent,
  }


}
