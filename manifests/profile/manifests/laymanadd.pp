# ## Class: profile::laymanadd
#
# Add the ``layman-add`` tool to ease layman overlay management.
#
class profile::laymanadd {

  # ### layman overlays
  layman {
    # * betagarden contains the layman-add tool
    'betagarden':
      ensure => present,
  } ~>
  # we need to sync eix after adding overlays so puppet sees them
  exec { 'sync-eix-for-betagarden':
    command     => '/usr/bin/eix-update',
    refreshonly => true,
  } ->
  # ### Packages
  portage::package {
    # * layman-add script for adding layman overlays from git and elsewhere
    'app-portage/layman-add':
      ensure   => present,
      keywords => [
        '~amd64',
      ]
  }

}
