# # Class: role::mcollective
#
class role::mcollective {
  include ::profile::system
  include ::profile::mcollective
}
