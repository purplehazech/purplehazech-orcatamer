# # Class: role::logstash
#
class role::logstash {
  include ::profile::system
  include ::profile::elasticsearch
  include ::profile::laymanadd
  include ::profile::logstash

  Class['::profile::system'] ->
  Class['::profile::elasticsearch'] ->
  Class['::profile::laymanadd'] ->
  Class['::profile::logstash']
}
