import 'profiles.pp'
import 'roles.pp'

node default {
  include ::profile::system
}
