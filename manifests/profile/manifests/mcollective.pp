# # Class: profile::mcollective
#
# Install an all in one mcollective master
#
class profile::mcollective {

  portage::package { 'net-misc/rabbitmq-server':
    ensure   => present,
    keywords => [
      '~amd64',
    ],
  } ->
  portage::package { 'app-admin/mcollective':
    # install the latest version from portage
    # I would prefer a much more modern mcollective and
    # might still reconsider this.
    ensure   => present,
    keywords => [
      '~amd64',
    ],
  } ->
  exec { 'rabbitmq-plugins-enable-all':
    command => '/usr/sbin/rabbitmq-plugins enable rabbitmq_stomp && /usr/sbin/rabbitmq-plugins enable rabbitmq_management',
    # the next line is clearly unsufficient
    creates => '/etc/rabbitmq/enabled_plugins',
    notify  => [
      Service['rabbitmq'],
      Exec['rabbitmqadmin-install']
    ],
  } ->
  augeas { 'configure-activemq-server':
    context => '/files/etc/mcollective/server.cfg',
    changes => [
      'set plugin.activemq.pool.1.host localhost',
      'set plugin.activemq.pool.1.port 61613',
      # these are the rabbitmq defaults
      'set plugin.activemq.pool.1.user guest',
      'set plugin.activemq.pool.1.password guest',
    ],
    notify  => [
      Service['mcollectived'],
      Service['rabbitmq'],
    ]
  } ->
  augeas { 'configure-activemq-client':
    context => '/files/etc/mcollective/client.cfg',
    changes => [
      'set plugin.activemq.pool.1.host localhost',
      'set plugin.activemq.pool.1.port 61613',
      # these are the rabbitmq defaults
      'set plugin.activemq.pool.1.user guest',
      'set plugin.activemq.pool.1.password guest',
    ],
  }

  #augeas { 'configure-rabbitmq-server':
  #  context => '/files/etc/rabbitmq/rabbitmq.conf/rabbitmq_stomp',
  #  lens    => 'Erlang.lns',
  #  incl    => '/etc/rabbitmq/rabbitmq.conf',
  #  changes => [
  #    'set default_user/login guest',
  #    'set default_user/passcode guest',
  #  ],
  #} ~>
  $mqadmin_cmd='/usr/bin/python2.7 /usr/local/bin/rabbitmqadmin'
  service { 'rabbitmq':
    ensure => running,
    enable => true,
  } ->
  exec { 'rabbitmqadmin-install':
    command => '/usr/bin/wget http://localhost:15672/cli/rabbitmqadmin --output-document=/usr/local/bin/rabbitmqadmin',
    creates => '/usr/local/bin/rabbitmqadmin',
  } ->
  file { '/usr/local/bin/rabbitmqadmin':
    ensure => present,
    mode   => '0755',
  } ->
  exec {
    'rabbitmq-declare-vhost-mcollective':
      command => "${mqadmin_cmd} declare vhost name=/mcollective",
      unless  => "${mqadmin_cmd} list vhosts -f bash | grep '/mcollective'";
    # @todo automate permissions
    # declare permission vhost=/mcollective user=guest configure='.*' write='.*' read='.*'
    'rabbitmq-declare-exchange-mcollective_broadcast':
      command => "${mqadmin_cmd} declare exchange --user=guest --password=guest --vhost=/mcollective name=mcollective_broadcast type=topic",
      unless  => "${mqadmin_cmd} list exchanges -V /mcollective  -f bash | grep 'mcollective_broadcast'";
    # @todo also declare name=mcollective_directed type=direct
  } ->
  service { 'mcollectived':
    ensure => running,
    enable => true,
  }

}
