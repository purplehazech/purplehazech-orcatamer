# ## Class: profile::puppet::master
#
# Contains the run book for installing a complete puppetmaster setup on
# a current gentoo node. Since this run book uses some highly experimental
# tooling it will not run on any platform other than gentoo anytime soon.
#
# The largest problems with this run book are as follows.
# * puppetdb is installed from binaries using leiningen
# * puppetboard is installed using pip
# * it should use postgresql as intended by puppetdb
#
# The rest of the run book is ready to be installed from binaries, so
# at least its got that going.
#
class profile::puppet::master {

  $optiz0r_overlay = 'git://github.com/optiz0r/gentoo-overlay.git'
  $rabe_overlay = 'git://github.com/purplehazech/rabe-portage-overlay.git'

  # ### PuppetDB
  # #### Overlays
  exec {
    # * optiz0r overlay has with leiningen
    'layman-add-optiz0r-overlay':
      command => "/usr/bin/layman-add optiz0r git ${optiz0r_overlay}",
      creates => '/var/lib/layman/optiz0r';
    # * rabe-portage-overlay has a more current puppetdb than optiz0r
    'layman-add-rabe-overlay':
      command => "/usr/bin/layman-add rabe git ${rabe_overlay}",
      creates => '/var/lib/layman/rabe',
  } ~>
  exec {
    # always run eix-sync after using layman-add manually
    # @todo abstraction for layman-add as puppet-module
    'sync-eix-for-puppetdb':
      command     => '/usr/bin/eix-update',
      refreshonly => true,
  } ->
  # #### Packages
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
  # #### Configuration
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

  # ### puppetboard
  $www_root        = '/var/www/puppet.vagrant.local/'
  $settings_file   = '/var/www/puppet.vagrant.local/settings.py'
  $wsgi_script     = '/var/www/puppet.vagrant.local/wsgi.py'
  $puppetboard_dir = '/usr/lib64/python2.7/site-packages/puppetboard/'
  $settings_tpl    = "${puppetboard_dir}/default_settings.py"
  # #### Packages
  package {
    # * pip is used due to puppetboard not being in portage (yet)
    'dev-python/pip':
      ensure  => present,
      require => Service['puppetdb'];
    # * nginx is used as a webserver since it is small, light and fast
    'www-servers/nginx':
      ensure => present,
  } ->
  portage::package {
    # * uwsgi will be used behind nginx as python thread manager
    'www-servers/uwsgi':
      ensure   => present,
      use      => [
        'python',
      ],
      keywords => [
        '~amd64',
      ],
  } ->
  # ### Pip Puppetboard Install
  exec {
    # Use python2.7 pip to ``pip install puppetboard``.
    'pip-install-puppetboard':
      command => '/usr/bin/python2.7 /usr/lib64/python2.7/site-packages/pip/__init__.py install puppetboard',
      creates => $puppetboard_dir,
  } ->
  file {
    # Make sure the nginx conf.d support is available.
    '/etc/nginx/conf.d':
      ensure => directory
  } ->
  # Let external nginx module do its magic.
  class { 'nginx': } ->
  exec {
    # rewrite gentoo nginx.conf to add conf.d support using sed in a quirky
    # manner due to the augeas Nginxconf.lns lens not supporting nested
    # configs ala gentoo.
    'nginx-add-conf.d':
      command => '/bin/sed --in-place -e "s@include /etc/nginx/mime.types;@include /etc/nginx/mime.types;\n\tinclude /etc/nginx/conf.d/*.conf;@" /etc/nginx/nginx.conf',
      unless  => '/bin/grep "include /etc/nginx/conf.d/\*.conf;" /etc/nginx/nginx.conf';
  } ~>
  exec {
    # Trigger nginx restart manually afterwards since the service is managed 
    # by the nginx class and I can't notify => it from here due to circular
    # dependency issues with that.
    'restart-nginx-after-conf':
      command     => '/etc/init.d/nginx restart',
      refreshonly => true
  }

  # ### Nginx Configuration
  nginx::resource::upstream {
    # Configure puppetboard as an upstream resource using nginx module.
    'puppetboard':
      ensure  => present,
      members => [
        '127.0.0.1:9090',
      ]
  } ->
  file {
    # Make sure the wwwroot exists and is readable.
    '/var/www/puppet.vagrant.local':
      ensure => directory,
      owner  => 'root',
      group  => 'nobody',
      mode   => '0766',
  } ->
  nginx::resource::vhost {
    # add puppetboard vhost to nginx config using a local template
    # made for puppetboard.
    # @todo Use the erb file as template after switch to being module.
    'puppet.vagrant.local' :
      listen_ip          => '0.0.0.0',
      default_server     => true,
      www_root           => '/var/www/puppet.vagrant.local',
      template_directory => '/vagrant/manifests/profile/templates/puppet/nginx_location.conf.erb',
  } ->
  # ### Puppetboard Configuration
  group {
    # Add ``puppetboard`` system group.
    'puppetboard':
      ensure => present,
      system => true,
  } ->
  user {
    # Add ``puppetboard`` system user.
    'puppetboard':
      ensure => present,
      system => true,
      gid    => 'puppetboard',
  } ->
  file {
    # Create logdir with ``puppetboard`` permissions.
    '/var/log/puppetboard/':
      ensure => directory,
      owner  => 'puppetboard',
      group  => 'puppetboard',
  } ->
  augeas {
    # Set basic uswgi options injected via UWSGI_EXTRA_OPTIONS in conf.d.
    'puppetboard-uwsgi':
      context => '/files/etc/conf.d/uwsgi.puppetboard',
      lens    => 'Shellvars.lns',
      incl    => '/etc/conf.d/uwsgi.puppetboard',
      changes => [
        'set UWSGI_USER puppetboard',
        'set UWSGI_GROUP puppetboard',
        'set UWSGI_LOG_FILE /var/log/puppetboard/uwsgi.log',
        'set UWSGI_DIR /var/www/puppet.vagrant.local',
        "set UWSGI_EXTRA_OPTIONS '\"--http 127.0.0.1:9090 --uwsgi-socket 127.0.0.1:9091 --plugin python27 --wsgi-file ${wsgi_script}\"'",
      ]
  } ->
  file { 
    # Create one-liner ``uwsgi.py`` python uwsgi runtime as per
    # puppetboard documentation.
    $wsgi_script:
      ensure  => file,
      content => 'from puppetboard.app import app as application',
      mode    => '0644',
  } ->
  file {
    # Create ``uwsgi.puppetboard`` symlink in gentoo uswgi config fashion.
    '/etc/init.d/uwsgi.puppetboard':
      ensure => link,
      target => '/etc/init.d/uwsgi',
  } ->
  service {
    # Start and enabel ``uswgi.puppetboard`` service.
    'uwsgi.puppetboard':
      ensure  => running,
      enable  => true,
      require => [
        Class['nginx'],
        Service['puppetmaster']
      ]
  }

  # ### Puppet Master install
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
  /*} ->
  service { 'puppet':
    ensure => running,
    enable => true,
  }*/
}
