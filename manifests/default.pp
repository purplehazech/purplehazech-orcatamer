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
